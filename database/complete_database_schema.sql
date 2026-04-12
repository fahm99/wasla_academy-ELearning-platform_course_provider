-- ============================================
-- منصة Wasla - قاعدة البيانات الكاملة والموحدة
-- ============================================
-- هذا الملف يجمع كافة أكواد قاعدة البيانات الصحيحة
-- التي يتم التعامل معها في تطبيق Flutter
-- ============================================

-- ============================================
-- القسم 1: الجداول الأساسية (Core Tables)
-- ============================================

-- ============================================
-- 1.1 جدول المستخدمين (users)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  avatar_url TEXT,
  profile_image_url TEXT,
  user_type VARCHAR(50) NOT NULL CHECK (user_type IN ('student', 'provider', 'admin')),
  bio TEXT,
  rating DECIMAL(3,2) DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  is_verified BOOLEAN DEFAULT FALSE,
  
  -- حقول إضافية للطلاب
  courses_enrolled INT DEFAULT 0,
  certificates_count INT DEFAULT 0,
  total_spent DECIMAL(10,2) DEFAULT 0,
  
  -- حقول إضافية لمقدمي الخدمات
  courses_count INT DEFAULT 0,
  students_count INT DEFAULT 0,
  total_earnings DECIMAL(10,2) DEFAULT 0,
  bank_account JSONB,
  
  -- حقول إضافية للإدمن
  permissions JSONB,
  last_login TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- ============================================
-- 1.2 جدول الكورسات (courses)
-- ============================================
CREATE TABLE IF NOT EXISTS courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(100),
  level VARCHAR(50) CHECK (level IN ('beginner', 'intermediate', 'advanced')),
  price DECIMAL(10,2) DEFAULT 0,
  currency VARCHAR(10) DEFAULT 'SAR',
  duration_hours INT,
  thumbnail_url TEXT,
  cover_image_url TEXT,
  certificate_template JSONB,
  status VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived', 'pending_review')),
  students_count INT DEFAULT 0,
  rating DECIMAL(3,2) DEFAULT 0,
  reviews_count INT DEFAULT 0,
  is_featured BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_courses_provider_id ON courses(provider_id);
CREATE INDEX IF NOT EXISTS idx_courses_status ON courses(status);
CREATE INDEX IF NOT EXISTS idx_courses_category ON courses(category);
CREATE INDEX IF NOT EXISTS idx_courses_level ON courses(level);
CREATE INDEX IF NOT EXISTS idx_courses_cover_image_url ON courses(cover_image_url) WHERE cover_image_url IS NOT NULL;

COMMENT ON COLUMN courses.cover_image_url IS 'رابط الصورة التعريفية (الغلاف) للكورس';
COMMENT ON COLUMN courses.certificate_template IS 'تصميم قالب الشهادة بصيغة JSON';

-- ============================================
-- 1.3 جدول الوحدات (modules)
-- ============================================
CREATE TABLE IF NOT EXISTS modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  order_number INT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_modules_course_id ON modules(course_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_modules_course_order ON modules(course_id, order_number);

-- ============================================
-- 1.4 جدول الدروس (lessons)
-- ============================================
CREATE TABLE IF NOT EXISTS lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  order_number INT NOT NULL,
  lesson_type VARCHAR(50) CHECK (lesson_type IN ('video', 'text', 'file', 'quiz')),
  video_url TEXT,
  video_duration INT,
  content TEXT,
  is_free BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lessons_module_id ON lessons(module_id);
CREATE INDEX IF NOT EXISTS idx_lessons_course_id ON lessons(course_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_lessons_module_order ON lessons(module_id, order_number);

-- ============================================
-- 1.5 جدول موارد الدروس (lesson_resources)
-- ============================================
CREATE TABLE IF NOT EXISTS lesson_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL,
  file_type VARCHAR(50) CHECK (file_type IN ('pdf', 'doc', 'image', 'zip', 'other')),
  file_size INT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lesson_resources_lesson_id ON lesson_resources(lesson_id);

-- ============================================
-- القسم 2: جداول التسجيل والتقدم
-- ============================================

-- ============================================
-- 2.1 جدول التسجيل (enrollments)
-- ============================================
CREATE TABLE IF NOT EXISTS enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  enrollment_date TIMESTAMP DEFAULT NOW(),
  completion_percentage INT DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
  status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'dropped')),
  payment_status VARCHAR(50) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded')),
  last_accessed TIMESTAMP,
  certificate_id UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(student_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id ON enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_status ON enrollments(status);

-- ============================================
-- 2.2 جدول تقدم الدروس (lesson_progress)
-- ============================================
CREATE TABLE IF NOT EXISTS lesson_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  is_completed BOOLEAN DEFAULT FALSE,
  watched_duration INT DEFAULT 0,
  completed_at TIMESTAMP,
  UNIQUE(student_id, lesson_id)
);

CREATE INDEX IF NOT EXISTS idx_lesson_progress_student_id ON lesson_progress(student_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_lesson_id ON lesson_progress(lesson_id);

-- ============================================
-- القسم 3: جداول الامتحانات
-- ============================================

-- ============================================
-- 3.1 جدول الامتحانات (exams)
-- ============================================
CREATE TABLE IF NOT EXISTS exams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  total_questions INT,
  passing_score INT,
  duration_minutes INT,
  status VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  allow_retake BOOLEAN DEFAULT TRUE,
  max_attempts INT DEFAULT 3,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exams_course_id ON exams(course_id);
CREATE INDEX IF NOT EXISTS idx_exams_status ON exams(status);

-- ============================================
-- 3.2 جدول أسئلة الامتحان (exam_questions)
-- ============================================
CREATE TABLE IF NOT EXISTS exam_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  question_type VARCHAR(50) CHECK (question_type IN ('multiple_choice', 'true_false', 'essay', 'short_answer')),
  options JSONB,
  correct_answer TEXT,
  points INT DEFAULT 1,
  order_number INT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exam_questions_exam_id ON exam_questions(exam_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_exam_questions_order ON exam_questions(exam_id, order_number);

-- ============================================
-- 3.3 جدول نتائج الامتحانات (exam_results)
-- ============================================
CREATE TABLE IF NOT EXISTS exam_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  score INT,
  total_score INT,
  percentage DECIMAL(5,2),
  passed BOOLEAN,
  attempt_number INT DEFAULT 1,
  completed_at TIMESTAMP,
  answers JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exam_results_exam_id ON exam_results(exam_id);
CREATE INDEX IF NOT EXISTS idx_exam_results_student_id ON exam_results(student_id);
CREATE INDEX IF NOT EXISTS idx_exam_results_passed ON exam_results(passed);

-- ============================================
-- القسم 4: جداول الشهادات
-- ============================================

-- ============================================
-- 4.1 جدول الشهادات (certificates)
-- ============================================
CREATE TABLE IF NOT EXISTS certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  certificate_number VARCHAR(100) UNIQUE NOT NULL,
  issue_date TIMESTAMP DEFAULT NOW(),
  expiry_date TIMESTAMP,
  template_design JSONB,
  certificate_url TEXT,
  status VARCHAR(50) DEFAULT 'issued' CHECK (status IN ('issued', 'revoked')),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_certificates_course_id ON certificates(course_id);
CREATE INDEX IF NOT EXISTS idx_certificates_student_id ON certificates(student_id);
CREATE INDEX IF NOT EXISTS idx_certificates_provider_id ON certificates(provider_id);
CREATE INDEX IF NOT EXISTS idx_certificates_status ON certificates(status);

-- ============================================
-- القسم 5: جداول المدفوعات
-- ============================================

-- ============================================
-- 5.1 جدول المدفوعات (payments)
-- ============================================
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'SAR',
  payment_method VARCHAR(50) CHECK (payment_method IN ('credit_card', 'apple_pay', 'google_pay', 'bank_transfer', 'local_transfer')),
  transaction_id VARCHAR(255) UNIQUE,
  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  payment_date TIMESTAMP,
  receipt_image_url TEXT,
  transaction_reference TEXT,
  student_name TEXT,
  course_name TEXT,
  verified_by UUID REFERENCES users(id),
  verified_at TIMESTAMP WITH TIME ZONE,
  rejection_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_student_id ON payments(student_id);
CREATE INDEX IF NOT EXISTS idx_payments_course_id ON payments(course_id);
CREATE INDEX IF NOT EXISTS idx_payments_provider_id ON payments(provider_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_provider_status ON payments(provider_id, status);

-- ============================================
-- 5.2 جدول إعدادات الدفع للمقدم (provider_payment_settings)
-- ============================================
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

CREATE INDEX IF NOT EXISTS idx_provider_payment_settings_provider ON provider_payment_settings(provider_id);

COMMENT ON TABLE provider_payment_settings IS 'إعدادات الدفع لمقدمي الخدمات';

-- ============================================
-- القسم 6: جداول الإشعارات والتقييمات
-- ============================================

-- ============================================
-- 6.1 جدول الإشعارات (notifications)
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  message TEXT,
  type VARCHAR(50) CHECK (type IN ('course', 'exam', 'certificate', 'payment', 'system')),
  related_id UUID,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);

-- ============================================
-- 6.2 جدول التقييمات (reviews)
-- ============================================
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reviews_course_id ON reviews(course_id);
CREATE INDEX IF NOT EXISTS idx_reviews_student_id ON reviews(student_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_reviews_unique ON reviews(course_id, student_id);

-- ============================================
-- القسم 7: جداول الإعدادات
-- ============================================

-- ============================================
-- 7.1 جدول الإعدادات (app_settings)
-- ============================================
CREATE TABLE IF NOT EXISTS app_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  theme VARCHAR(50) DEFAULT 'light' CHECK (theme IN ('light', 'dark')),
  language VARCHAR(10) DEFAULT 'ar' CHECK (language IN ('ar', 'en')),
  notifications_enabled BOOLEAN DEFAULT TRUE,
  email_notifications BOOLEAN DEFAULT TRUE,
  push_notifications BOOLEAN DEFAULT TRUE,
  notify_new_students BOOLEAN DEFAULT TRUE,
  notify_new_reviews BOOLEAN DEFAULT TRUE,
  notify_new_payments BOOLEAN DEFAULT TRUE,
  auto_save BOOLEAN DEFAULT TRUE,
  settings_data JSONB,
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_settings_user_id ON app_settings(user_id);

COMMENT ON COLUMN app_settings.push_notifications IS 'تفعيل الإشعارات الفورية';
COMMENT ON COLUMN app_settings.notify_new_students IS 'إشعار عند انضمام طالب جديد';
COMMENT ON COLUMN app_settings.notify_new_reviews IS 'إشعار عند تلقي تقييم جديد';
COMMENT ON COLUMN app_settings.notify_new_payments IS 'إشعار عند تلقي دفعة جديدة';
COMMENT ON COLUMN app_settings.auto_save IS 'الحفظ التلقائي للتغييرات';

-- ============================================
-- القسم 8: تفعيل Row Level Security (RLS)
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE exam_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE exam_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider_payment_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- ============================================
-- القسم 9: سياسات الأمان (RLS Policies)
-- ============================================

-- ============================================
-- 9.1 سياسات جدول users
-- ============================================

DROP POLICY IF EXISTS "Users can view own profile" ON users;
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON users;
CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON users;
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- ============================================
-- 9.2 سياسات جدول courses
-- ============================================

DROP POLICY IF EXISTS "Students can view published courses" ON courses;
CREATE POLICY "Students can view published courses"
  ON courses FOR SELECT
  USING (status = 'published' OR provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can view their courses" ON courses;
CREATE POLICY "Providers can view their courses"
  ON courses FOR SELECT
  USING (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can insert their courses" ON courses;
CREATE POLICY "Providers can insert their courses"
  ON courses FOR INSERT
  WITH CHECK (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can update their courses" ON courses;
CREATE POLICY "Providers can update their courses"
  ON courses FOR UPDATE
  USING (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can delete their courses" ON courses;
CREATE POLICY "Providers can delete their courses"
  ON courses FOR DELETE
  USING (provider_id = auth.uid());

-- ============================================
-- 9.3 سياسات جدول modules
-- ============================================

DROP POLICY IF EXISTS "Providers can view modules" ON modules;
CREATE POLICY "Providers can view modules"
  ON modules FOR SELECT
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can insert modules" ON modules;
CREATE POLICY "Providers can insert modules"
  ON modules FOR INSERT
  WITH CHECK (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can update modules" ON modules;
CREATE POLICY "Providers can update modules"
  ON modules FOR UPDATE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can delete modules" ON modules;
CREATE POLICY "Providers can delete modules"
  ON modules FOR DELETE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

-- ============================================
-- 9.4 سياسات جدول lessons
-- ============================================

DROP POLICY IF EXISTS "Providers can view lessons" ON lessons;
CREATE POLICY "Providers can view lessons"
  ON lessons FOR SELECT
  USING (module_id IN (
    SELECT m.id FROM modules m 
    JOIN courses c ON m.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Providers can insert lessons" ON lessons;
CREATE POLICY "Providers can insert lessons"
  ON lessons FOR INSERT
  WITH CHECK (module_id IN (
    SELECT m.id FROM modules m 
    JOIN courses c ON m.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Providers can update lessons" ON lessons;
CREATE POLICY "Providers can update lessons"
  ON lessons FOR UPDATE
  USING (module_id IN (
    SELECT m.id FROM modules m 
    JOIN courses c ON m.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Providers can delete lessons" ON lessons;
CREATE POLICY "Providers can delete lessons"
  ON lessons FOR DELETE
  USING (module_id IN (
    SELECT m.id FROM modules m 
    JOIN courses c ON m.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

-- ============================================
-- 9.5 سياسات جدول enrollments
-- ============================================

DROP POLICY IF EXISTS "Students can view their enrollments" ON enrollments;
CREATE POLICY "Students can view their enrollments"
  ON enrollments FOR SELECT
  USING (student_id = auth.uid());

DROP POLICY IF EXISTS "Providers can view their students" ON enrollments;
CREATE POLICY "Providers can view their students"
  ON enrollments FOR SELECT
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can update enrollments" ON enrollments;
CREATE POLICY "Providers can update enrollments"
  ON enrollments FOR UPDATE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

-- ============================================
-- 9.6 سياسات جدول lesson_progress
-- ============================================

DROP POLICY IF EXISTS "Students can view their progress" ON lesson_progress;
CREATE POLICY "Students can view their progress"
  ON lesson_progress FOR SELECT
  USING (student_id = auth.uid());

-- ============================================
-- 9.7 سياسات جدول exams
-- ============================================

DROP POLICY IF EXISTS "Providers can view exams" ON exams;
CREATE POLICY "Providers can view exams"
  ON exams FOR SELECT
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can insert exams" ON exams;
CREATE POLICY "Providers can insert exams"
  ON exams FOR INSERT
  WITH CHECK (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can update exams" ON exams;
CREATE POLICY "Providers can update exams"
  ON exams FOR UPDATE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can delete exams" ON exams;
CREATE POLICY "Providers can delete exams"
  ON exams FOR DELETE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

-- ============================================
-- 9.8 سياسات جدول exam_questions
-- ============================================

DROP POLICY IF EXISTS "Providers can view exam questions" ON exam_questions;
CREATE POLICY "Providers can view exam questions"
  ON exam_questions FOR SELECT
  USING (exam_id IN (
    SELECT e.id FROM exams e 
    JOIN courses c ON e.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Providers can insert exam questions" ON exam_questions;
CREATE POLICY "Providers can insert exam questions"
  ON exam_questions FOR INSERT
  WITH CHECK (exam_id IN (
    SELECT e.id FROM exams e 
    JOIN courses c ON e.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Providers can update exam questions" ON exam_questions;
CREATE POLICY "Providers can update exam questions"
  ON exam_questions FOR UPDATE
  USING (exam_id IN (
    SELECT e.id FROM exams e 
    JOIN courses c ON e.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Providers can delete exam questions" ON exam_questions;
CREATE POLICY "Providers can delete exam questions"
  ON exam_questions FOR DELETE
  USING (exam_id IN (
    SELECT e.id FROM exams e 
    JOIN courses c ON e.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

-- ============================================
-- 9.9 سياسات جدول exam_results
-- ============================================

DROP POLICY IF EXISTS "Students can view their exam results" ON exam_results;
CREATE POLICY "Students can view their exam results"
  ON exam_results FOR SELECT
  USING (student_id = auth.uid());

DROP POLICY IF EXISTS "Providers can view exam results for their courses" ON exam_results;
CREATE POLICY "Providers can view exam results for their courses"
  ON exam_results FOR SELECT
  USING (exam_id IN (SELECT id FROM exams WHERE course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())));

-- ============================================
-- 9.10 سياسات جدول certificates
-- ============================================

DROP POLICY IF EXISTS "Students can view their certificates" ON certificates;
CREATE POLICY "Students can view their certificates"
  ON certificates FOR SELECT
  USING (student_id = auth.uid());

DROP POLICY IF EXISTS "Providers can view certificates" ON certificates;
CREATE POLICY "Providers can view certificates"
  ON certificates FOR SELECT
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can insert certificates" ON certificates;
CREATE POLICY "Providers can insert certificates"
  ON certificates FOR INSERT
  WITH CHECK (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can update certificates" ON certificates;
CREATE POLICY "Providers can update certificates"
  ON certificates FOR UPDATE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

-- ============================================
-- 9.11 سياسات جدول payments
-- ============================================

DROP POLICY IF EXISTS "Providers can view payments" ON payments;
CREATE POLICY "Providers can view payments"
  ON payments FOR SELECT
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can update payments" ON payments;
CREATE POLICY "Providers can update payments"
  ON payments FOR UPDATE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

-- ============================================
-- 9.12 سياسات جدول provider_payment_settings
-- ============================================

DROP POLICY IF EXISTS "Providers can view their payment settings" ON provider_payment_settings;
CREATE POLICY "Providers can view their payment settings"
  ON provider_payment_settings FOR SELECT
  USING (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can insert their payment settings" ON provider_payment_settings;
CREATE POLICY "Providers can insert their payment settings"
  ON provider_payment_settings FOR INSERT
  WITH CHECK (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can update their payment settings" ON provider_payment_settings;
CREATE POLICY "Providers can update their payment settings"
  ON provider_payment_settings FOR UPDATE
  USING (provider_id = auth.uid());

-- ============================================
-- 9.13 سياسات جدول notifications
-- ============================================

DROP POLICY IF EXISTS "Users can view their notifications" ON notifications;
CREATE POLICY "Users can view their notifications"
  ON notifications FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert notifications" ON notifications;
CREATE POLICY "Users can insert notifications"
  ON notifications FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update their notifications" ON notifications;
CREATE POLICY "Users can update their notifications"
  ON notifications FOR UPDATE
  USING (user_id = auth.uid());

-- ============================================
-- 9.14 سياسات جدول app_settings
-- ============================================

DROP POLICY IF EXISTS "Users can view their settings" ON app_settings;
CREATE POLICY "Users can view their settings"
  ON app_settings FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert their settings" ON app_settings;
CREATE POLICY "Users can insert their settings"
  ON app_settings FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update their settings" ON app_settings;
CREATE POLICY "Users can update their settings"
  ON app_settings FOR UPDATE
  USING (user_id = auth.uid());

-- ============================================
-- القسم 10: الدوال والـ Triggers
-- ============================================


-- ============================================
-- 10.1 Trigger: إنشاء سجل في جدول users تلقائياً
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $
DECLARE
  v_user_type TEXT;
  v_name      TEXT;
  v_phone     TEXT;
BEGIN
  -- قراءة البيانات من metadata
  v_user_type := COALESCE(NEW.raw_user_meta_data->>'user_type', 'provider');
  v_name      := COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1));
  v_phone     := NEW.raw_user_meta_data->>'phone';

  -- التحقق من أن النوع صحيح، وإلا نضع provider افتراضياً
  IF v_user_type NOT IN ('student', 'provider', 'admin') THEN
    v_user_type := 'provider';
  END IF;

  -- إدراج السجل الأساسي المشترك بين جميع الأنواع
  INSERT INTO public.users (
    id, email, name, phone, user_type,
    is_verified, is_active,
    courses_enrolled, certificates_count, total_spent,
    courses_count, students_count, total_earnings,
    created_at, updated_at
  )
  VALUES (
    NEW.id, NEW.email, v_name, v_phone, v_user_type,
    FALSE, TRUE,
    0, 0, 0,
    0, 0, 0,
    NOW(), NOW()
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.users TO postgres, service_role;

-- ============================================
-- 10.2 دالة لتحديث عدد الطلاب في الكورس
-- ============================================

CREATE OR REPLACE FUNCTION update_course_students_count()
RETURNS TRIGGER AS $
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE courses SET students_count = students_count + 1 WHERE id = NEW.course_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE courses SET students_count = students_count - 1 WHERE id = OLD.course_id;
  END IF;
  RETURN NULL;
END;
$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_course_students_count ON enrollments;

CREATE TRIGGER trigger_update_course_students_count
AFTER INSERT OR DELETE ON enrollments
FOR EACH ROW
EXECUTE FUNCTION update_course_students_count();

-- ============================================
-- 10.3 دالة لتحديث عدد الكورسات لمقدم الخدمة
-- ============================================

CREATE OR REPLACE FUNCTION update_provider_courses_count()
RETURNS TRIGGER AS $
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE users SET courses_count = courses_count + 1 WHERE id = NEW.provider_id AND user_type = 'provider';
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE users SET courses_count = courses_count - 1 WHERE id = OLD.provider_id AND user_type = 'provider';
  END IF;
  RETURN NULL;
END;
$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_provider_courses_count ON courses;

CREATE TRIGGER trigger_update_provider_courses_count
AFTER INSERT OR DELETE ON courses
FOR EACH ROW
EXECUTE FUNCTION update_provider_courses_count();

-- ============================================
-- 10.4 دالة لتحديث حالة الدفع
-- ============================================

CREATE OR REPLACE FUNCTION update_payment_status(
  p_payment_id UUID,
  p_new_status TEXT,
  p_verified_by UUID,
  p_rejection_reason TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $
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
        student_id, course_id, enrollment_date,
        status, payment_status, completion_percentage
      ) VALUES (
        v_student_id, v_course_id, NOW(),
        'active', 'paid', 0
      );
    END IF;
    
    -- جلب اسم الكورس
    SELECT title INTO v_course_name FROM courses WHERE id = v_course_id;
    
    -- إرسال إشعار للطالب بالموافقة
    INSERT INTO notifications (
      user_id, title, message, type, related_id, is_read, created_at
    ) VALUES (
      v_student_id,
      'تم تأكيد الدفع',
      'تم تأكيد دفعتك للكورس "' || v_course_name || '". يمكنك الآن الوصول إلى محتوى الكورس.',
      'payment', v_course_id, FALSE, NOW()
    );
    
  ELSIF p_new_status = 'failed' THEN
    -- إرسال إشعار للطالب بالرفض
    SELECT title INTO v_course_name FROM courses WHERE id = v_course_id;
    
    INSERT INTO notifications (
      user_id, title, message, type, related_id, is_read, created_at
    ) VALUES (
      v_student_id,
      'تم رفض الدفع',
      'تم رفض دفعتك للكورس "' || v_course_name || '". ' || COALESCE('السبب: ' || p_rejection_reason, 'يرجى التواصل مع مقدم الخدمة.'),
      'payment', v_course_id, FALSE, NOW()
    );
  END IF;
  
  RETURN TRUE;
END;
$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_payment_status IS 'تحديث حالة الدفع وتفعيل وصول الطالب للكورس';

-- ============================================
-- 10.5 Trigger لتحديث updated_at في provider_payment_settings
-- ============================================

CREATE OR REPLACE FUNCTION update_provider_payment_settings_updated_at()
RETURNS TRIGGER AS $
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_provider_payment_settings_updated_at ON provider_payment_settings;

CREATE TRIGGER trigger_update_provider_payment_settings_updated_at
  BEFORE UPDATE ON provider_payment_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_provider_payment_settings_updated_at();

-- ============================================
-- 10.6 Trigger للإصدار التلقائي للشهادات
-- ============================================

CREATE OR REPLACE FUNCTION auto_issue_certificate()
RETURNS TRIGGER AS $
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
        course_id, student_id, provider_id,
        certificate_number, issue_date, status,
        created_at
      ) VALUES (
        v_course_id, NEW.student_id, v_provider_id,
        v_certificate_number, NOW(), 'issued',
        NOW()
      );
      
      -- إرسال إشعار للطالب
      INSERT INTO notifications (
        user_id, title, message, type, related_id, is_read, created_at
      ) VALUES (
        NEW.student_id,
        'تم إصدار شهادتك',
        'تهانينا! تم إصدار شهادة إتمام الكورس تلقائياً',
        'certificate', v_course_id, FALSE, NOW()
      );
      
      -- إرسال إشعار لمقدم الخدمة
      INSERT INTO notifications (
        user_id, title, message, type, related_id, is_read, created_at
      ) VALUES (
        v_provider_id,
        'تم إصدار شهادة جديدة',
        'تم إصدار شهادة تلقائياً لطالب أكمل الكورس',
        'certificate', v_course_id, FALSE, NOW()
      );
      
    END IF;
  END IF;
  
  RETURN NEW;
END;
$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_auto_issue_certificate ON enrollments;

CREATE TRIGGER trigger_auto_issue_certificate
  AFTER UPDATE ON enrollments
  FOR EACH ROW
  WHEN (NEW.status = 'completed')
  EXECUTE FUNCTION auto_issue_certificate();

COMMENT ON FUNCTION auto_issue_certificate() IS 'يصدر شهادة تلقائياً عندما يكمل الطالب الكورس';
COMMENT ON TRIGGER trigger_auto_issue_certificate ON enrollments IS 'يستدعي دالة الإصدار التلقائي للشهادات';

-- ============================================
-- القسم 11: إنشاء Storage Buckets
-- ============================================

-- 1. إنشاء bucket للفيديوهات
INSERT INTO storage.buckets (id, name, public)
VALUES ('course-videos', 'course-videos', true)
ON CONFLICT (id) DO NOTHING;

-- 2. إنشاء bucket للملفات
INSERT INTO storage.buckets (id, name, public)
VALUES ('course-files', 'course-files', true)
ON CONFLICT (id) DO NOTHING;

-- 3. إنشاء bucket للصور
INSERT INTO storage.buckets (id, name, public)
VALUES ('course-images', 'course-images', true)
ON CONFLICT (id) DO NOTHING;

-- 4. إنشاء bucket للشهادات
INSERT INTO storage.buckets (id, name, public)
VALUES ('certificates', 'certificates', false)
ON CONFLICT (id) DO NOTHING;

-- 5. إنشاء bucket للصور الشخصية
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- القسم 12: RLS Policies للـ Storage Buckets
-- ============================================

-- ============================================
-- 12.1 Policies لـ course-videos
-- ============================================

CREATE POLICY "Providers can upload videos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'course-videos' AND
  auth.uid() IN (SELECT id FROM users WHERE user_type = 'provider')
);

CREATE POLICY "Providers can update their videos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'course-videos' AND
  auth.uid() IN (SELECT id FROM users WHERE user_type = 'provider')
);

CREATE POLICY "Providers can delete their videos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'course-videos' AND
  auth.uid() IN (SELECT id FROM users WHERE user_type = 'provider')
);

CREATE POLICY "Anyone can view videos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'course-videos');

-- ============================================
-- 12.2 Policies لـ course-files
-- ============================================

CREATE POLICY "Providers can upload files"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'course-files' AND
  auth.uid() IN (SELECT id FROM users WHERE user_type = 'provider')
);

CREATE POLICY "Providers can update their files"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'course-files' AND
  auth.uid() IN (SELECT id FROM users WHERE user_type = 'provider')
);

CREATE POLICY "Providers can delete their files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'course-files' AND
  auth.uid() IN (SELECT id FROM users WHERE user_type = 'provider')
);

CREATE POLICY "Anyone can view files"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'course-files');

-- ============================================
-- 12.3 Policies لـ course-images
-- ============================================

CREATE POLICY "Providers can upload images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'course-images' AND
  auth.uid() IN (SELECT id FROM users WHERE user_type = 'provider')
);

CREATE POLICY "Providers can update their images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'course-images' AND
  auth.uid() IN (SELECT id FROM users WHERE user_type = 'provider')
);

CREATE POLICY "Providers can delete their images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'course-images' AND
  auth.uid() IN (SELECT id FROM users WHERE user_type = 'provider')
);

CREATE POLICY "Anyone can view images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'course-images');

-- ============================================
-- 12.4 Policies لـ certificates
-- ============================================

CREATE POLICY "Providers can upload certificates"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'certificates' AND
  auth.uid() IN (SELECT id FROM users WHERE user_type = 'provider')
);

CREATE POLICY "Users can view their certificates"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'certificates' AND
  (
    auth.uid() IN (SELECT id FROM users WHERE user_type = 'provider') OR
    name LIKE '%' || auth.uid()::text || '%'
  )
);

-- ============================================
-- 12.5 Policies لـ avatars
-- ============================================

CREATE POLICY "Users can upload their avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'profiles' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

CREATE POLICY "Users can update their avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'profiles' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

CREATE POLICY "Users can delete their avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'profiles' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- ============================================
-- القسم 13: ملاحظات مهمة
-- ============================================

-- ملاحظات:
-- 1. تأكد من تشغيل هذا السكريبت في Supabase SQL Editor
-- 2. تأكد من تفعيل RLS على جميع الجداول
-- 3. يمكنك تعديل الـ policies حسب احتياجاتك
-- 4. الـ buckets العامة (public: true) تسمح بالوصول المباشر للملفات
-- 5. الـ buckets الخاصة (public: false) تحتاج signed URLs للوصول
-- 6. تم إزالة عمود password_hash من جدول users لأن Supabase يتولى المصادقة
-- 7. جميع الـ Triggers والدوال تعمل تلقائياً
-- 8. نظام المدفوعات يدعم الدفع المحلي والتحويل البنكي
-- 9. الشهادات تصدر تلقائياً عند إكمال الكورس
-- 10. الإشعارات ترسل تلقائياً للأحداث المهمة

-- ============================================
-- انتهى الملف الموحد لقاعدة البيانات
-- ============================================
