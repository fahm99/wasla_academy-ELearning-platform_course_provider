-- Trigger للإصدار التلقائي للشهادات عند إكمال الكورس

-- Function لإصدار الشهادة تلقائياً
CREATE OR REPLACE FUNCTION auto_issue_certificate()
RETURNS TRIGGER AS $$
DECLARE
  v_course_id UUID;
  v_provider_id UUID;
  v_certificate_number TEXT;
  v_existing_certificate UUID;
BEGIN
  -- التحقق من أن الحالة الجديدة هي completed
  IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
    
    -- جلب معلومات الكورس
    SELECT id, provider_id INTO v_course_id, v_provider_id
    FROM courses
    WHERE id = NEW.course_id;
    
    -- التحقق من عدم وجود شهادة سابقة
    SELECT id INTO v_existing_certificate
    FROM certificates
    WHERE course_id = NEW.course_id
      AND student_id = NEW.student_id
    LIMIT 1;
    
    -- إصدار الشهادة فقط إذا لم تكن موجودة
    IF v_existing_certificate IS NULL THEN
      
      -- توليد رقم الشهادة
      v_certificate_number := 'CERT-' || 
                             TO_CHAR(NOW(), 'YYYYMMDD') || '-' ||
                             TO_CHAR(NOW(), 'HH24MISS') || '-' ||
                             FLOOR(RANDOM() * 10000)::TEXT;
      
      -- إنشاء الشهادة
      INSERT INTO certificates (
        course_id,
        student_id,
        provider_id,
        certificate_number,
        issue_date,
        status,
        created_at,
        updated_at
      ) VALUES (
        v_course_id,
        NEW.student_id,
        v_provider_id,
        v_certificate_number,
        NOW(),
        'issued',
        NOW(),
        NOW()
      );
      
      -- إرسال إشعار للطالب
      INSERT INTO notifications (
        user_id,
        title,
        message,
        type,
        related_id,
        is_read,
        created_at
      ) VALUES (
        NEW.student_id,
        'تم إصدار شهادتك',
        'تهانينا! تم إصدار شهادة إتمام الكورس تلقائياً',
        'certificate',
        v_course_id,
        FALSE,
        NOW()
      );
      
      -- إرسال إشعار لمقدم الخدمة
      INSERT INTO notifications (
        user_id,
        title,
        message,
        type,
        related_id,
        is_read,
        created_at
      ) VALUES (
        v_provider_id,
        'تم إصدار شهادة جديدة',
        'تم إصدار شهادة تلقائياً لطالب أكمل الكورس',
        'certificate',
        v_course_id,
        FALSE,
        NOW()
      );
      
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إنشاء Trigger
DROP TRIGGER IF EXISTS trigger_auto_issue_certificate ON enrollments;

CREATE TRIGGER trigger_auto_issue_certificate
  AFTER UPDATE ON enrollments
  FOR EACH ROW
  WHEN (NEW.status = 'completed')
  EXECUTE FUNCTION auto_issue_certificate();

-- تعليق توضيحي
COMMENT ON FUNCTION auto_issue_certificate() IS 'يصدر شهادة تلقائياً عندما يكمل الطالب الكورس';
COMMENT ON TRIGGER trigger_auto_issue_certificate ON enrollments IS 'يستدعي دالة الإصدار التلقائي للشهادات';
