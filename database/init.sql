-- ============================================
-- منصة Wasla - SQL Scripts الشاملة
-- ============================================

-- ============================================
-- 1. جدول المستخدمين (users)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
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
-- 2. جدول الكورسات (courses)
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

-- ============================================
-- 3. جدول الوحدات (modules)
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
-- 4. جدول الدروس (lessons)
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
-- 5. جدول موارد الدروس (lesson_resources)
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
-- 6. جدول التسجيل (enrollments)
-- ============================================
CREATE TABLE IF NOT EXISTS enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  enrollment_date TIMESTAMP DEFAULT NOW(),
  completion_percentage INT DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
  status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'dropped')),
  last_accessed TIMESTAMP,
  certificate_id UUID,
  UNIQUE(student_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id ON enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_status ON enrollments(status);

-- ============================================
-- 7. جدول تقدم الدروس (lesson_progress)
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
-- 8. جدول الامتحانات (exams)
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
-- 9. جدول أسئلة الامتحان (exam_questions)
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
-- 10. جدول نتائج الامتحانات (exam_results)
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
-- 11. جدول الشهادات (certificates)
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
-- 12. جدول المدفوعات (payments)
-- ============================================
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'SAR',
  payment_method VARCHAR(50) CHECK (payment_method IN ('credit_card', 'apple_pay', 'google_pay', 'bank_transfer')),
  transaction_id VARCHAR(255) UNIQUE,
  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  payment_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_student_id ON payments(student_id);
CREATE INDEX IF NOT EXISTS idx_payments_course_id ON payments(course_id);
CREATE INDEX IF NOT EXISTS idx_payments_provider_id ON payments(provider_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

-- ============================================
-- 13. جدول الإشعارات (notifications)
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
-- 14. جدول التقييمات (reviews)
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
-- 15. جدول الإعدادات (app_settings)
-- ============================================
CREATE TABLE IF NOT EXISTS app_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  theme VARCHAR(50) DEFAULT 'light' CHECK (theme IN ('light', 'dark')),
  language VARCHAR(10) DEFAULT 'ar' CHECK (language IN ('ar', 'en')),
  notifications_enabled BOOLEAN DEFAULT TRUE,
  email_notifications BOOLEAN DEFAULT TRUE,
  settings_data JSONB,
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_settings_user_id ON app_settings(user_id);

-- ============================================
-- تفعيل Row Level Security (RLS)
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
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- ============================================
-- سياسات الأمان للطلاب
-- ============================================

-- الطلاب يرون فقط الكورسات المنشورة
CREATE POLICY "Students can view published courses"
  ON courses FOR SELECT
  USING (status = 'published' OR provider_id = auth.uid());

-- الطلاب يرون فقط بيانات التسجيل الخاصة بهم
CREATE POLICY "Students can view their enrollments"
  ON enrollments FOR SELECT
  USING (student_id = auth.uid());

-- الطلاب يرون فقط نتائجهم الخاصة
CREATE POLICY "Students can view their exam results"
  ON exam_results FOR SELECT
  USING (student_id = auth.uid());

-- الطلاب يرون فقط تقدمهم الخاص
CREATE POLICY "Students can view their progress"
  ON lesson_progress FOR SELECT
  USING (student_id = auth.uid());

-- الطلاب يرون فقط شهاداتهم الخاصة
CREATE POLICY "Students can view their certificates"
  ON certificates FOR SELECT
  USING (student_id = auth.uid());

-- الطلاب يرون فقط إشعاراتهم الخاصة
CREATE POLICY "Students can view their notifications"
  ON notifications FOR SELECT
  USING (user_id = auth.uid());

-- ============================================
-- سياسات الأمان لمقدمي الخدمات
-- ============================================

-- مقدمو الخدمات يرون فقط كورساتهم الخاصة
CREATE POLICY "Providers can view their courses"
  ON courses FOR SELECT
  USING (provider_id = auth.uid());

-- مقدمو الخدمات يمكنهم تعديل كورساتهم فقط
CREATE POLICY "Providers can update their courses"
  ON courses FOR UPDATE
  USING (provider_id = auth.uid());

-- مقدمو الخدمات يمكنهم حذف كورساتهم فقط
CREATE POLICY "Providers can delete their courses"
  ON courses FOR DELETE
  USING (provider_id = auth.uid());

-- مقدمو الخدمات يرون فقط طلاب كورساتهم
CREATE POLICY "Providers can view their students"
  ON enrollments FOR SELECT
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

-- مقدمو الخدمات يرون فقط نتائج امتحانات كورساتهم
CREATE POLICY "Providers can view exam results for their courses"
  ON exam_results FOR SELECT
  USING (exam_id IN (SELECT id FROM exams WHERE course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())));

-- ============================================
-- سياسات الأمان للإدمن
-- ============================================

-- الإدمن يرون كل شيء (يتم التحقق من الدور في التطبيق)
-- يمكن إضافة سياسات إضافية حسب الحاجة

-- ============================================
-- إنشاء Buckets للتخزين
-- ============================================

-- تم إنشاء Buckets يدويًا في Supabase Dashboard:
-- 1. course-videos (للفيديوهات)
-- 2. course-files (للملفات)
-- 3. course-images (للصور)
-- 4. certificates (للشهادات)
-- 5. avatars (للصور الشخصية)

-- ============================================
-- دوال مساعدة
-- ============================================

-- دالة لتحديث عدد الطلاب في الكورس
CREATE OR REPLACE FUNCTION update_course_students_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE courses SET students_count = students_count + 1 WHERE id = NEW.course_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE courses SET students_count = students_count - 1 WHERE id = OLD.course_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger لتحديث عدد الطلاب
CREATE TRIGGER trigger_update_course_students_count
AFTER INSERT OR DELETE ON enrollments
FOR EACH ROW
EXECUTE FUNCTION update_course_students_count();

-- دالة لتحديث عدد الكورسات لمقدم الخدمة
CREATE OR REPLACE FUNCTION update_provider_courses_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE users SET courses_count = courses_count + 1 WHERE id = NEW.provider_id AND user_type = 'provider';
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE users SET courses_count = courses_count - 1 WHERE id = OLD.provider_id AND user_type = 'provider';
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger لتحديث عدد الكورسات
CREATE TRIGGER trigger_update_provider_courses_count
AFTER INSERT OR DELETE ON courses
FOR EACH ROW
EXECUTE FUNCTION update_provider_courses_count();

-- ============================================
-- انتهى SQL Scripts
-- ============================================
