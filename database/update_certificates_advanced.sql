-- إضافة حقول جديدة لجدول certificates
ALTER TABLE certificates 
ADD COLUMN IF NOT EXISTS template_data JSONB,
ADD COLUMN IF NOT EXISTS certificate_url TEXT,
ADD COLUMN IF NOT EXISTS verification_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS is_auto_issued BOOLEAN DEFAULT false;

-- إضافة جدول قوالب الشهادات
CREATE TABLE IF NOT EXISTS certificate_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  is_default BOOLEAN DEFAULT false,
  template_data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إضافة فهارس
CREATE INDEX IF NOT EXISTS idx_certificates_verification ON certificates(verification_code);
CREATE INDEX IF NOT EXISTS idx_certificate_templates_provider ON certificate_templates(provider_id);
CREATE INDEX IF NOT EXISTS idx_certificate_templates_course ON certificate_templates(course_id);

-- RLS Policies
ALTER TABLE certificate_templates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Providers can view their templates" ON certificate_templates;
CREATE POLICY "Providers can view their templates"
  ON certificate_templates FOR SELECT
  USING (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can insert their templates" ON certificate_templates;
CREATE POLICY "Providers can insert their templates"
  ON certificate_templates FOR INSERT
  WITH CHECK (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can update their templates" ON certificate_templates;
CREATE POLICY "Providers can update their templates"
  ON certificate_templates FOR UPDATE
  USING (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can delete their templates" ON certificate_templates;
CREATE POLICY "Providers can delete their templates"
  ON certificate_templates FOR DELETE
  USING (provider_id = auth.uid());

-- دالة لتوليد رمز التحقق الفريد
CREATE OR REPLACE FUNCTION generate_verification_code()
RETURNS TEXT AS $$
DECLARE
  code TEXT;
  exists BOOLEAN;
BEGIN
  LOOP
    code := 'WAS-' || LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
    SELECT EXISTS(SELECT 1 FROM certificates WHERE verification_code = code) INTO exists;
    EXIT WHEN NOT exists;
  END LOOP;
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Trigger لتوليد رمز التحقق تلقائياً
CREATE OR REPLACE FUNCTION set_verification_code()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.verification_code IS NULL THEN
    NEW.verification_code := generate_verification_code();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_set_verification_code ON certificates;
CREATE TRIGGER trigger_set_verification_code
  BEFORE INSERT ON certificates
  FOR EACH ROW
  EXECUTE FUNCTION set_verification_code();

-- Trigger للإصدار التلقائي للشهادات
CREATE OR REPLACE FUNCTION auto_issue_certificate()
RETURNS TRIGGER AS $$
DECLARE
  course_record RECORD;
  student_record RECORD;
  provider_record RECORD;
  template_record RECORD;
  total_lessons INT;
  completed_lessons INT;
  exam_passed BOOLEAN;
  cert_exists BOOLEAN;
BEGIN
  -- التحقق من أن الطالب أكمل الكورس
  SELECT c.* INTO course_record FROM courses c WHERE c.id = NEW.course_id;
  SELECT u.* INTO student_record FROM users u WHERE u.id = NEW.student_id;
  SELECT u.* INTO provider_record FROM users u WHERE u.id = course_record.provider_id;
  
  -- حساب عدد الدروس المكتملة
  SELECT COUNT(*) INTO total_lessons 
  FROM lessons l 
  JOIN modules m ON l.module_id = m.id 
  WHERE m.course_id = NEW.course_id;
  
  SELECT COUNT(*) INTO completed_lessons
  FROM lesson_progress lp
  JOIN lessons l ON lp.lesson_id = l.id
  JOIN modules m ON l.module_id = m.id
  WHERE m.course_id = NEW.course_id 
    AND lp.student_id = NEW.student_id 
    AND lp.is_completed = true;
  
  -- التحقق من اجتياز الامتحان
  SELECT EXISTS(
    SELECT 1 FROM exam_results er
    JOIN exams e ON er.exam_id = e.id
    WHERE e.course_id = NEW.course_id
      AND er.student_id = NEW.student_id
      AND er.passed = true
  ) INTO exam_passed;
  
  -- التحقق من عدم وجود شهادة سابقة
  SELECT EXISTS(
    SELECT 1 FROM certificates
    WHERE course_id = NEW.course_id
      AND student_id = NEW.student_id
  ) INTO cert_exists;
  
  -- إصدار الشهادة إذا تحققت الشروط
  IF total_lessons > 0 AND completed_lessons = total_lessons AND exam_passed AND NOT cert_exists THEN
    -- جلب القالب الافتراضي
    SELECT * INTO template_record 
    FROM certificate_templates 
    WHERE provider_id = course_record.provider_id 
      AND (course_id = NEW.course_id OR course_id IS NULL)
      AND is_default = true
    LIMIT 1;
    
    INSERT INTO certificates (
      course_id,
      student_id,
      student_name,
      student_email,
      course_name,
      provider_id,
      provider_name,
      certificate_number,
      issue_date,
      completion_date,
      status,
      is_auto_issued,
      template_data
    ) VALUES (
      NEW.course_id,
      NEW.student_id,
      student_record.name,
      student_record.email,
      course_record.title,
      course_record.provider_id,
      provider_record.name,
      'CERT-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 10)),
      NOW(),
      NOW(),
      'issued',
      true,
      COALESCE(template_record.template_data, '{}'::jsonb)
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_auto_issue_certificate ON lesson_progress;
CREATE TRIGGER trigger_auto_issue_certificate
  AFTER INSERT OR UPDATE ON lesson_progress
  FOR EACH ROW
  WHEN (NEW.is_completed = true)
  EXECUTE FUNCTION auto_issue_certificate();
