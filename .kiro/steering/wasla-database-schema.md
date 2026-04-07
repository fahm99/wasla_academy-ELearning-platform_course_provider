---
inclusion: manual
---

# 📊 SQL Scripts - إنشاء جداول قاعدة البيانات

## تعليمات الاستخدام
انسخ هذه الـ Scripts وقم بتنفيذها في Supabase SQL Editor

---

## 1️⃣ جدول المستخدمين (users)

```sql
CREATE TABLE users (
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

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_is_active ON users(is_active);
```

---

## 2️⃣ جدول الكورسات (courses)

```sql
CREATE TABLE courses (
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

CREATE INDEX idx_courses_provider_id ON courses(provider_id);
CREATE INDEX idx_courses_status ON courses(status);
CREATE INDEX idx_courses_category ON courses(category);
CREATE INDEX idx_courses_level ON courses(level);
```

---

## 3️⃣ جدول الوحدات (modules)

```sql
CREATE TABLE modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  order_number INT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_modules_course_id ON modules(course_id);
CREATE UNIQUE INDEX idx_modules_course_order ON modules(course_id, order_number);
```

---

## 4️⃣ جدول الدروس (lessons)

```sql
CREATE TABLE lessons (
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

CREATE INDEX idx_lessons_module_id ON lessons(module_id);
CREATE INDEX idx_lessons_course_id ON lessons(course_id);
CREATE UNIQUE INDEX idx_lessons_module_order ON lessons(module_id, order_number);
```

---

## 5️⃣ جدول موارد الدروس (lesson_resources)

```sql
CREATE TABLE lesson_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL,
  file_type VARCHAR(50) CHECK (file_type IN ('pdf', 'doc', 'image', 'zip', 'other')),
  file_size INT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_lesson_resources_lesson_id ON lesson_resources(lesson_id);
```

---

## 6️⃣ جدول التسجيل (enrollments)

```sql
CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  enrollment_date TIMESTAMP DEFAULT NOW(),
  completion_percentage INT DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
  status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'dropped')),
  last_accessed TIMESTAMP,
  certificate_id UUID REFERENCES certificates(id),
  UNIQUE(student_id, course_id)
);

CREATE INDEX idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX idx_enrollments_course_id ON enrollments(course_id);
CREATE INDEX idx_enrollments_status ON enrollments(status);
```

---

## 7️⃣ جدول تقدم الدروس (lesson_progress)

```sql
CREATE TABLE lesson_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  is_completed BOOLEAN DEFAULT FALSE,
  watched_duration INT DEFAULT 0,
  completed_at TIMESTAMP,
  UNIQUE(student_id, lesson_id)
);

CREATE INDEX idx_lesson_progress_student_id ON lesson_progress(student_id);
CREATE INDEX idx_lesson_progress_lesson_id ON lesson_progress(lesson_id);
```

---

## 8️⃣ جدول الامتحانات (exams)

```sql
CREATE TABLE exams (
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

CREATE INDEX idx_exams_course_id ON exams(course_id);
CREATE INDEX idx_exams_status ON exams(status);
```

---

## 9️⃣ جدول أسئلة الامتحان (exam_questions)

```sql
CREATE TABLE exam_questions (
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

CREATE INDEX idx_exam_questions_exam_id ON exam_questions(exam_id);
CREATE UNIQUE INDEX idx_exam_questions_order ON exam_questions(exam_id, order_number);
```

---

## 🔟 جدول نتائج الامتحانات (exam_results)

```sql
CREATE TABLE exam_results (
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

CREATE INDEX idx_exam_results_exam_id ON exam_results(exam_id);
CREATE INDEX idx_exam_results_student_id ON exam_results(student_id);
CREATE INDEX idx_exam_results_passed ON exam_results(passed);
```

---

## 1️⃣1️⃣ جدول الشهادات (certificates)

```sql
CREATE TABLE certificates (
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

CREATE INDEX idx_certificates_course_id ON certificates(course_id);
CREATE INDEX idx_certificates_student_id ON certificates(student_id);
CREATE INDEX idx_certificates_provider_id ON certificates(provider_id);
CREATE INDEX idx_certificates_status ON certificates(status);
```

---

## 1️⃣2️⃣ جدول المدفوعات (payments)

```sql
CREATE TABLE payments (
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

CREATE INDEX idx_payments_student_id ON payments(student_id);
CREATE INDEX idx_payments_course_id ON payments(course_id);
CREATE INDEX idx_payments_provider_id ON payments(provider_id);
CREATE INDEX idx_payments_status ON payments(status);
```

---

## 1️⃣3️⃣ جدول الإشعارات (notifications)

```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  message TEXT,
  type VARCHAR(50) CHECK (type IN ('course', 'exam', 'certificate', 'payment', 'system')),
  related_id UUID,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
```

---

## 1️⃣4️⃣ جدول التقييمات (reviews)

```sql
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_reviews_course_id ON reviews(course_id);
CREATE INDEX idx_reviews_student_id ON reviews(student_id);
CREATE UNIQUE INDEX idx_reviews_unique ON reviews(course_id, student_id);
```

---

## 1️⃣5️⃣ جدول الإعدادات (app_settings)

```sql
CREATE TABLE app_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  theme VARCHAR(50) DEFAULT 'light' CHECK (theme IN ('light', 'dark')),
  language VARCHAR(10) DEFAULT 'ar' CHECK (language IN ('ar', 'en')),
  notifications_enabled BOOLEAN DEFAULT TRUE,
  email_notifications BOOLEAN DEFAULT TRUE,
  settings_data JSONB,
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_app_settings_user_id ON app_settings(user_id);
```

---

## 🔐 سياسات الأمان (Row Level Security)

### تفعيل RLS على جميع الجداول

```sql
-- تفعيل RLS
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
```

### سياسات للطلاب

```sql
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
```

### سياسات لمقدمي الخدمات

```sql
-- مقدمو الخدمات يرون فقط كورساتهم الخاصة
CREATE POLICY "Providers can view their courses"
  ON courses FOR SELECT
  USING (provider_id = auth.uid());

-- مقدمو الخدمات يمكنهم تعديل كورساتهم فقط
CREATE POLICY "Providers can update their courses"
  ON courses FOR UPDATE
  USING (provider_id = auth.uid());

-- مقدمو الخدمات يرون فقط طلاب كورساتهم
CREATE POLICY "Providers can view their students"
  ON enrollments FOR SELECT
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

-- مقدمو الخدمات يرون فقط نتائج امتحانات كورساتهم
CREATE POLICY "Providers can view exam results for their courses"
  ON exam_results FOR SELECT
  USING (exam_id IN (SELECT id FROM exams WHERE course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())));
```

### سياسات للإدمن

```sql
-- الإدمن يرون كل شيء
CREATE POLICY "Admins can view all data"
  ON users FOR SELECT
  USING (auth.jwt() ->> 'user_type' = 'admin');

CREATE POLICY "Admins can view all courses"
  ON courses FOR SELECT
  USING (auth.jwt() ->> 'user_type' = 'admin');

-- يمكن إضافة سياسات مماثلة لجميع الجداول
```

---

## 📝 ملاحظات مهمة

1. **الفهارس**: تم إضافة فهارس على الحقول المستخدمة بكثرة لتحسين الأداء
2. **القيود**: تم إضافة CHECK constraints للتحقق من صحة البيانات
3. **المفاتيح الأجنبية**: تم استخدام ON DELETE CASCADE لحذف البيانات المرتبطة
4. **RLS**: يجب تفعيل RLS على جميع الجداول لضمان الأمان
5. **التواريخ**: جميع الجداول تحتوي على created_at و updated_at للتتبع

---

## 🚀 خطوات التنفيذ

1. انسخ جميع SQL Scripts
2. افتح Supabase SQL Editor
3. قم بتنفيذ Scripts الجداول بالترتيب
4. قم بتنفيذ Scripts RLS
5. تحقق من أن جميع الجداول تم إنشاؤها بنجاح
6. اختبر الاتصال من التطبيق
