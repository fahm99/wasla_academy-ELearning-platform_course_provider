---
inclusion: manual
---

# 📋 خطة التكامل الشاملة لمنصة Wasla مع Supabase

## 🎯 نظرة عامة
منصة تعليمية متكاملة تدعم ثلاثة أدوار رئيسية:
- **الطالب (Student)**: يتعلم ويشتري الكورسات ويحصل على شهادات
- **مقدم الخدمة (Provider)**: ينشئ ويدير الكورسات والطلاب والشهادات
- **الإدمن (Admin)**: يراقب ويدير المنصة بالكامل

---

## 📊 هيكل قاعدة البيانات الموحدة

### 1️⃣ جدول المستخدمين (users)
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  avatar_url TEXT,
  profile_image_url TEXT,
  user_type VARCHAR(50) NOT NULL, -- 'student', 'provider', 'admin'
  bio TEXT,
  rating DECIMAL(3,2) DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

**الحقول الإضافية حسب النوع:**
- **Student**: `courses_enrolled INT`, `certificates_count INT`, `total_spent DECIMAL`
- **Provider**: `courses_count INT`, `students_count INT`, `total_earnings DECIMAL`, `bank_account JSONB`
- **Admin**: `permissions JSONB`, `last_login TIMESTAMP`

---

### 2️⃣ جدول الكورسات (courses)
```sql
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(100),
  level VARCHAR(50), -- 'beginner', 'intermediate', 'advanced'
  price DECIMAL(10,2) DEFAULT 0, -- 0 = مجاني
  currency VARCHAR(10) DEFAULT 'SAR',
  duration_hours INT,
  thumbnail_url TEXT,
  cover_image_url TEXT,
  status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'published', 'archived', 'pending_review'
  students_count INT DEFAULT 0,
  rating DECIMAL(3,2) DEFAULT 0,
  reviews_count INT DEFAULT 0,
  is_featured BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

### 3️⃣ جدول الوحدات (modules)
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
```

---

### 4️⃣ جدول الدروس (lessons)
```sql
CREATE TABLE lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  order_number INT NOT NULL,
  lesson_type VARCHAR(50), -- 'video', 'text', 'file', 'quiz'
  video_url TEXT,
  video_duration INT, -- بالثواني
  content TEXT,
  is_free BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

### 5️⃣ جدول موارد الدروس (lesson_resources)
```sql
CREATE TABLE lesson_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL,
  file_type VARCHAR(50), -- 'pdf', 'doc', 'image', 'zip'
  file_size INT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

### 6️⃣ جدول التسجيل (enrollments)
```sql
CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  enrollment_date TIMESTAMP DEFAULT NOW(),
  completion_percentage INT DEFAULT 0,
  status VARCHAR(50) DEFAULT 'active', -- 'active', 'completed', 'dropped'
  last_accessed TIMESTAMP,
  certificate_id UUID REFERENCES certificates(id),
  UNIQUE(student_id, course_id)
);
```

---

### 7️⃣ جدول تقدم الدروس (lesson_progress)
```sql
CREATE TABLE lesson_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  is_completed BOOLEAN DEFAULT FALSE,
  watched_duration INT DEFAULT 0, -- بالثواني
  completed_at TIMESTAMP,
  UNIQUE(student_id, lesson_id)
);
```

---

### 8️⃣ جدول الامتحانات (exams)
```sql
CREATE TABLE exams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  total_questions INT,
  passing_score INT,
  duration_minutes INT,
  status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'published'
  allow_retake BOOLEAN DEFAULT TRUE,
  max_attempts INT DEFAULT 3,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

### 9️⃣ جدول أسئلة الامتحان (exam_questions)
```sql
CREATE TABLE exam_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  question_type VARCHAR(50), -- 'multiple_choice', 'true_false', 'essay'
  options JSONB, -- [{"id": 1, "text": "الخيار 1"}, ...]
  correct_answer TEXT,
  points INT DEFAULT 1,
  order_number INT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

### 🔟 جدول نتائج الامتحانات (exam_results)
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
```

---

### 1️⃣1️⃣ جدول الشهادات (certificates)
```sql
CREATE TABLE certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  certificate_number VARCHAR(100) UNIQUE NOT NULL,
  issue_date TIMESTAMP DEFAULT NOW(),
  expiry_date TIMESTAMP,
  template_design JSONB, -- {logo, signature, colors, fonts}
  certificate_url TEXT,
  status VARCHAR(50) DEFAULT 'issued', -- 'issued', 'revoked'
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

### 1️⃣2️⃣ جدول المدفوعات (payments)
```sql
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'SAR',
  payment_method VARCHAR(50), -- 'credit_card', 'apple_pay', 'google_pay'
  transaction_id VARCHAR(255) UNIQUE,
  status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'completed', 'failed', 'refunded'
  payment_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

### 1️⃣3️⃣ جدول الإشعارات (notifications)
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  message TEXT,
  type VARCHAR(50), -- 'course', 'exam', 'certificate', 'payment', 'system'
  related_id UUID,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

### 1️⃣4️⃣ جدول التقييمات (reviews)
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
```

---

### 1️⃣5️⃣ جدول الإعدادات (app_settings)
```sql
CREATE TABLE app_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  theme VARCHAR(50) DEFAULT 'light',
  language VARCHAR(10) DEFAULT 'ar',
  notifications_enabled BOOLEAN DEFAULT TRUE,
  email_notifications BOOLEAN DEFAULT TRUE,
  settings_data JSONB,
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🔐 سياسات الأمان (Row Level Security - RLS)

### للطلاب:
- يرى فقط الكورسات المنشورة
- يرى فقط بيانات التسجيل الخاصة به
- يرى فقط نتائجه الخاصة

### لمقدمي الخدمات:
- يرى فقط كورساته الخاصة
- يرى فقط طلاب كورساته
- يرى فقط نتائج امتحانات كورساته

### للإدمن:
- يرى كل شيء
- يمكنه تعديل أي بيانات

---

## 🏗️ هيكل المشروع

```
lib/
├── models/
│   ├── user.dart
│   ├── course.dart
│   ├── module.dart
│   ├── lesson.dart
│   ├── enrollment.dart
│   ├── exam.dart
│   ├── exam_question.dart
│   ├── exam_result.dart
│   ├── certificate.dart
│   ├── payment.dart
│   ├── notification.dart
│   ├── review.dart
│   └── index.dart
├── services/
│   ├── supabase_service.dart (الخدمة الرئيسية)
│   ├── auth_service.dart
│   ├── course_service.dart
│   ├── student_service.dart
│   ├── exam_service.dart
│   ├── certificate_service.dart
│   ├── payment_service.dart
│   ├── storage_service.dart
│   └── notification_service.dart
├── repository/
│   ├── supabase_repository.dart
│   └── main_repository.dart
├── bloc/
│   ├── auth/
│   ├── course/
│   ├── enrollment/
│   ├── exam/
│   ├── certificate/
│   ├── payment/
│   ├── notification/
│   └── bloc.dart
├── screens/
├── widgets/
├── theme/
├── utils/
└── main.dart
```

---

## 📱 الوظائف حسب الدور

### 🎓 الطالب (Student)
- ✅ التسجيل والمصادقة
- ✅ تصفح الكورسات
- ✅ البحث والفلترة
- ✅ الاشتراك (مجاني/مدفوع)
- ✅ مشاهدة الدروس
- ✅ تتبع التقدم
- ✅ حل الامتحانات
- ✅ الحصول على الشهادات
- ✅ تقييم الكورسات
- ✅ إدارة الملف الشخصي

### 🧑‍🏫 مقدم الخدمة (Provider)
- ✅ التسجيل والمصادقة
- ✅ إنشاء/تعديل/حذف الكورسات
- ✅ إدارة الوحدات والدروس
- ✅ رفع الفيديوهات والملفات
- ✅ إنشاء الامتحانات
- ✅ متابعة الطلاب
- ✅ عرض النتائج
- ✅ إدارة الشهادات
- ✅ تخصيص قوالب الشهادات
- ✅ الإصدار التلقائي للشهادات
- ✅ إدارة الملف الشخصي

### 🛡️ الإدمن (Admin)
- ✅ إدارة المستخدمين
- ✅ مراجعة مقدمي الخدمات
- ✅ مراجعة الكورسات
- ✅ مراقبة المدفوعات
- ✅ إدارة الشهادات
- ✅ إرسال إشعارات عامة
- ✅ مراقبة الأداء
- ✅ إدارة الإعدادات العامة

---

## 🚀 خطوات التنفيذ

### المرحلة 1: الإعداد الأساسي
1. إضافة حزم Supabase
2. إنشاء جداول قاعدة البيانات
3. تكوين سياسات الأمان

### المرحلة 2: طبقة الخدمات
1. إنشاء SupabaseService
2. إنشاء خدمات متخصصة لكل وظيفة

### المرحلة 3: النماذج والـ Repository
1. تحديث النماذج
2. إنشاء SupabaseRepository

### المرحلة 4: BLoCs
1. تحديث BLoCs الموجودة
2. إنشاء BLoCs جديدة

### المرحلة 5: الواجهات
1. تحديث الشاشات الموجودة
2. إنشاء شاشات جديدة

---

## 📝 ملاحظات مهمة

- قاعدة البيانات موحدة تدعم جميع الأدوار
- كل دور له صلاحيات محددة عبر RLS
- التطبيقات (Student App و Provider App) تستخدم نفس قاعدة البيانات
- الأمان والخصوصية مضمونة عبر سياسات الصفوف
