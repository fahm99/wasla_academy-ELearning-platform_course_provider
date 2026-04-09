-- تحديث نظام المدفوعات للدفع المحلي

-- 1. تحديث جدول payments لإضافة الحقول الجديدة
ALTER TABLE payments
ADD COLUMN IF NOT EXISTS receipt_image_url TEXT,
ADD COLUMN IF NOT EXISTS transaction_reference TEXT,
ADD COLUMN IF NOT EXISTS student_name TEXT,
ADD COLUMN IF NOT EXISTS course_name TEXT,
ADD COLUMN IF NOT EXISTS verified_by UUID REFERENCES users(id),
ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- 2. إنشاء جدول إعدادات الدفع للمقدم
CREATE TABLE IF NOT EXISTS provider_payment_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  wallet_number TEXT,
  wallet_owner_name TEXT,
  bank_name TEXT,
  bank_account_number TEXT,
  bank_account_owner_name TEXT,
  iban TEXT,
  additional_info TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(provider_id)
);

-- 3. إنشاء فهرس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_payments_provider_status ON payments(provider_id, status);
CREATE INDEX IF NOT EXISTS idx_payments_student_id ON payments(student_id);
CREATE INDEX IF NOT EXISTS idx_provider_payment_settings_provider ON provider_payment_settings(provider_id);

-- 4. Function لتحديث حالة الدفع
CREATE OR REPLACE FUNCTION update_payment_status(
  p_payment_id UUID,
  p_new_status TEXT,
  p_verified_by UUID,
  p_rejection_reason TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_student_id UUID;
  v_course_id UUID;
  v_provider_id UUID;
  v_course_name TEXT;
  v_old_status TEXT;
BEGIN
  -- جلب معلومات الدفع
  SELECT student_id, course_id, provider_id, status
  INTO v_student_id, v_course_id, v_provider_id, v_old_status
  FROM payments
  WHERE id = p_payment_id;
  
  -- التحقق من وجود الدفع
  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;
  
  -- تحديث حالة الدفع
  UPDATE payments
  SET 
    status = p_new_status,
    verified_by = p_verified_by,
    verified_at = NOW(),
    rejection_reason = p_rejection_reason,
    updated_at = NOW()
  WHERE id = p_payment_id;
  
  -- إذا تم تأكيد الدفع، تفعيل وصول الطالب للكورس
  IF p_new_status = 'completed' THEN
    -- التحقق من وجود تسجيل
    IF EXISTS (SELECT 1 FROM enrollments WHERE student_id = v_student_id AND course_id = v_course_id) THEN
      -- تحديث التسجيل الموجود
      UPDATE enrollments
      SET 
        status = 'active',
        payment_status = 'paid',
        updated_at = NOW()
      WHERE student_id = v_student_id AND course_id = v_course_id;
    ELSE
      -- إنشاء تسجيل جديد
      INSERT INTO enrollments (
        student_id,
        course_id,
        enrollment_date,
        status,
        payment_status,
        completion_percentage
      ) VALUES (
        v_student_id,
        v_course_id,
        NOW(),
        'active',
        'paid',
        0
      );
    END IF;
    
    -- جلب اسم الكورس
    SELECT title INTO v_course_name FROM courses WHERE id = v_course_id;
    
    -- إرسال إشعار للطالب بالموافقة
    INSERT INTO notifications (
      user_id,
      title,
      message,
      type,
      related_id,
      is_read,
      created_at
    ) VALUES (
      v_student_id,
      'تم تأكيد الدفع',
      'تم تأكيد دفعتك للكورس "' || v_course_name || '". يمكنك الآن الوصول إلى محتوى الكورس.',
      'payment',
      v_course_id,
      FALSE,
      NOW()
    );
    
  ELSIF p_new_status = 'failed' THEN
    -- إرسال إشعار للطالب بالرفض
    SELECT title INTO v_course_name FROM courses WHERE id = v_course_id;
    
    INSERT INTO notifications (
      user_id,
      title,
      message,
      type,
      related_id,
      is_read,
      created_at
    ) VALUES (
      v_student_id,
      'تم رفض الدفع',
      'تم رفض دفعتك للكورس "' || v_course_name || '". ' || COALESCE('السبب: ' || p_rejection_reason, 'يرجى التواصل مع مقدم الخدمة.'),
      'payment',
      v_course_id,
      FALSE,
      NOW()
    );
  END IF;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- 5. Trigger لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_provider_payment_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_provider_payment_settings_updated_at ON provider_payment_settings;

CREATE TRIGGER trigger_update_provider_payment_settings_updated_at
  BEFORE UPDATE ON provider_payment_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_provider_payment_settings_updated_at();

-- 6. إضافة تعليقات توضيحية
COMMENT ON TABLE provider_payment_settings IS 'إعدادات الدفع لمقدمي الخدمات';
COMMENT ON FUNCTION update_payment_status IS 'تحديث حالة الدفع وتفعيل وصول الطالب للكورس';

-- 7. منح الصلاحيات
ALTER TABLE provider_payment_settings ENABLE ROW LEVEL SECURITY;

-- سياسة للقراءة: المقدم يمكنه قراءة إعداداته فقط
CREATE POLICY provider_payment_settings_select_policy ON provider_payment_settings
  FOR SELECT
  USING (provider_id = auth.uid());

-- سياسة للإدراج: المقدم يمكنه إنشاء إعداداته
CREATE POLICY provider_payment_settings_insert_policy ON provider_payment_settings
  FOR INSERT
  WITH CHECK (provider_id = auth.uid());

-- سياسة للتحديث: المقدم يمكنه تحديث إعداداته
CREATE POLICY provider_payment_settings_update_policy ON provider_payment_settings
  FOR UPDATE
  USING (provider_id = auth.uid());
