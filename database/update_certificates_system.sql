-- ============================================
-- تحديث نظام الشهادات
-- ============================================

-- إضافة عمود completed_at لجدول enrollments إذا لم يكن موجوداً
ALTER TABLE enrollments 
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP;

-- إضافة أعمدة جديدة لجدول certificates
ALTER TABLE certificates 
ADD COLUMN IF NOT EXISTS provider_logo_url TEXT,
ADD COLUMN IF NOT EXISTS provider_signature_url TEXT,
ADD COLUMN IF NOT EXISTS custom_color VARCHAR(20) DEFAULT '#1E3A8A',
ADD COLUMN IF NOT EXISTS auto_issue BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS grade VARCHAR(10),
ADD COLUMN IF NOT EXISTS completion_date TIMESTAMP;

-- إضافة أعمدة لجدول courses لحفظ إعدادات الشهادات
ALTER TABLE courses
ADD COLUMN IF NOT EXISTS certificate_auto_issue BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS certificate_logo_url TEXT,
ADD COLUMN IF NOT EXISTS certificate_signature_url TEXT,
ADD COLUMN IF NOT EXISTS certificate_custom_color VARCHAR(20) DEFAULT '#1E3A8A';

-- تحديث الفهارس
CREATE INDEX IF NOT EXISTS idx_certificates_certificate_number ON certificates(certificate_number);
CREATE INDEX IF NOT EXISTS idx_certificates_auto_issue ON certificates(auto_issue);

-- دالة للتحقق من أهلية الطالب للحصول على الشهادة
CREATE OR REPLACE FUNCTION check_student_eligibility(
  p_student_id UUID,
  p_course_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
  v_enrollment_exists BOOLEAN;
  v_progress INTEGER;
  v_exam_passed BOOLEAN;
BEGIN
  -- التحقق من التسجيل
  SELECT EXISTS(
    SELECT 1 FROM enrollments 
    WHERE student_id = p_student_id 
    AND course_id = p_course_id
    AND status = 'active'
  ) INTO v_enrollment_exists;
  
  IF NOT v_enrollment_exists THEN
    RETURN FALSE;
  END IF;
  
  -- التحقق من إكمال الكورس (100%)
  SELECT completion_percentage INTO v_progress
  FROM enrollments
  WHERE student_id = p_student_id 
  AND course_id = p_course_id;
  
  IF v_progress < 100 THEN
    RETURN FALSE;
  END IF;
  
  -- التحقق من النجاح في الامتحان (إذا وجد)
  SELECT EXISTS(
    SELECT 1 FROM exam_results er
    JOIN exams e ON er.exam_id = e.id
    WHERE e.course_id = p_course_id
    AND er.student_id = p_student_id
    AND er.passed = TRUE
  ) INTO v_exam_passed;
  
  -- إذا كان هناك امتحان، يجب النجاح فيه
  IF EXISTS(SELECT 1 FROM exams WHERE course_id = p_course_id) THEN
    RETURN v_exam_passed;
  END IF;
  
  -- إذا لم يكن هناك امتحان، الطالب مؤهل
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- دالة للحصول على الطلاب المؤهلين للحصول على الشهادة
CREATE OR REPLACE FUNCTION get_eligible_students(p_course_id UUID)
RETURNS TABLE (
  student_id UUID,
  student_name TEXT,
  student_email TEXT,
  progress INTEGER,
  exam_score INTEGER,
  completion_date TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    e.student_id,
    u.name,
    u.email,
    e.completion_percentage as progress,
    COALESCE(er.score, 0) as exam_score,
    e.completed_at as completion_date
  FROM enrollments e
  JOIN users u ON e.student_id = u.id
  LEFT JOIN (
    SELECT DISTINCT ON (er.student_id) 
      er.student_id,
      er.score,
      er.passed
    FROM exam_results er
    JOIN exams ex ON er.exam_id = ex.id
    WHERE ex.course_id = p_course_id
    ORDER BY er.student_id, er.created_at DESC
  ) er ON e.student_id = er.student_id
  WHERE e.course_id = p_course_id
  AND e.completion_percentage = 100
  AND e.status = 'active'
  AND (
    NOT EXISTS(SELECT 1 FROM exams WHERE course_id = p_course_id)
    OR er.passed = TRUE
  )
  AND NOT EXISTS(
    SELECT 1 FROM certificates 
    WHERE course_id = p_course_id 
    AND student_id = e.student_id
    AND status = 'issued'
  )
  ORDER BY e.completed_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Trigger للإصدار التلقائي للشهادات
CREATE OR REPLACE FUNCTION auto_issue_certificate()
RETURNS TRIGGER AS $$
DECLARE
  v_auto_issue BOOLEAN;
  v_certificate_number TEXT;
  v_provider_id UUID;
  v_logo_url TEXT;
  v_signature_url TEXT;
  v_custom_color TEXT;
BEGIN
  -- التحقق من تفعيل الإصدار التلقائي
  SELECT 
    certificate_auto_issue,
    provider_id,
    certificate_logo_url,
    certificate_signature_url,
    certificate_custom_color
  INTO 
    v_auto_issue,
    v_provider_id,
    v_logo_url,
    v_signature_url,
    v_custom_color
  FROM courses
  WHERE id = NEW.course_id;
  
  -- إذا كان الإصدار التلقائي مفعلاً والطالب أكمل الكورس
  IF v_auto_issue AND NEW.completion_percentage = 100 AND NEW.status = 'active' THEN
    -- التحقق من عدم وجود شهادة سابقة
    IF NOT EXISTS(
      SELECT 1 FROM certificates 
      WHERE course_id = NEW.course_id 
      AND student_id = NEW.student_id
    ) THEN
      -- التحقق من الأهلية (النجاح في الامتحان إذا وجد)
      IF check_student_eligibility(NEW.student_id, NEW.course_id) THEN
        -- توليد رقم الشهادة
        v_certificate_number := 'CERT-' || 
          TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
          TO_CHAR(NOW(), 'HH24MISS') || '-' || 
          FLOOR(RANDOM() * 10000)::TEXT;
        
        -- إصدار الشهادة
        INSERT INTO certificates (
          course_id,
          student_id,
          provider_id,
          certificate_number,
          issue_date,
          completion_date,
          provider_logo_url,
          provider_signature_url,
          custom_color,
          auto_issue,
          status
        ) VALUES (
          NEW.course_id,
          NEW.student_id,
          v_provider_id,
          v_certificate_number,
          NOW(),
          NEW.completed_at,
          v_logo_url,
          v_signature_url,
          v_custom_color,
          TRUE,
          'issued'
        );
        
        -- إرسال إشعار للطالب
        INSERT INTO notifications (
          user_id,
          title,
          message,
          type,
          related_id
        ) VALUES (
          NEW.student_id,
          'تم إصدار شهادتك',
          'تهانينا! تم إصدار شهادة إتمام الكورس تلقائياً',
          'certificate',
          NEW.course_id
        );
      END IF;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إنشاء Trigger
DROP TRIGGER IF EXISTS trigger_auto_issue_certificate ON enrollments;
CREATE TRIGGER trigger_auto_issue_certificate
AFTER UPDATE OF completion_percentage ON enrollments
FOR EACH ROW
WHEN (NEW.completion_percentage = 100 AND OLD.completion_percentage < 100)
EXECUTE FUNCTION auto_issue_certificate();

-- Trigger لتحديث completed_at عند إكمال الكورس
CREATE OR REPLACE FUNCTION update_enrollment_completed_at()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.completion_percentage = 100 AND (OLD.completion_percentage < 100 OR OLD.completed_at IS NULL) THEN
    NEW.completed_at := NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_completed_at ON enrollments;
CREATE TRIGGER trigger_update_completed_at
BEFORE UPDATE OF completion_percentage ON enrollments
FOR EACH ROW
EXECUTE FUNCTION update_enrollment_completed_at();

-- تعليق على الجدول
COMMENT ON TABLE certificates IS 'جدول الشهادات مع دعم الإصدار التلقائي والتخصيص';
COMMENT ON COLUMN certificates.provider_logo_url IS 'رابط شعار مقدم الخدمة';
COMMENT ON COLUMN certificates.provider_signature_url IS 'رابط توقيع مقدم الخدمة';
COMMENT ON COLUMN certificates.custom_color IS 'اللون المخصص للشهادة';
COMMENT ON COLUMN certificates.auto_issue IS 'هل تم إصدار الشهادة تلقائياً';
COMMENT ON COLUMN certificates.grade IS 'التقدير (A+, A, B+, إلخ)';
COMMENT ON COLUMN certificates.completion_date IS 'تاريخ إكمال الكورس';
