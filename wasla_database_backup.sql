-- ============================================
-- Wasla Academy Database - Full Backup
-- تاريخ الإنشاء: 2026-04-13
-- ============================================
-- هذا الملف يحتوي على كامل بنية قاعدة بيانات Wasla Academy
-- بما في ذلك الجداول، السياسات، الدوال، التريجرز، والـ Storage Buckets
-- ============================================

-- ============================================
-- 1. تفعيل الإضافات المطلوبة (Extensions)
-- ============================================

-- تفعيل UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- تفعيل pgcrypto للتشفير
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 2. إنشاء الجداول (Tables)
-- ============================================

-- جدول المستخدمين
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR NOT NULL UNIQUE,
    name VARCHAR NOT NULL,
    phone VARCHAR,
    avatar_url TEXT,
    profile_image_url TEXT,
    user_type VARCHAR NOT NULL CHECK (user_type IN ('student', 'provider', 'admin')),
    bio TEXT,
    rating NUMERIC DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    
    -- حقول خاصة بالطلاب
    courses_enrolled INTEGER DEFAULT 0,
    certificates_count INTEGER DEFAULT 0,
    total_spent NUMERIC DEFAULT 0,
    
    -- حقول خاصة بمقدمي الخدمات
    courses_count INTEGER DEFAULT 0,
    students_count INTEGER DEFAULT 0,
    total_earnings NUMERIC DEFAULT 0,
    bank_account JSONB,
    
    -- حقول خاصة بالمسؤولين
    permissions JSONB,
    
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- جدول الكورسات
CREATE TABLE IF NOT EXISTS public.courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title VARCHAR NOT NULL,
    description TEXT,
    category VARCHAR,
    level VARCHAR CHECK (level IN ('beginner', 'intermediate', 'advanced')),
    price NUMERIC DEFAULT 0 CHECK (price >= 0),
    currency VARCHAR DEFAULT 'SAR',
    duration_hours INTEGER,
    thumbnail_url TEXT,
    cover_image_url TEXT COMMENT 'رابط الصورة التعريفية (الغلاف) للكورس',
    status VARCHAR DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived', 'pending_review')),
    students_count INTEGER DEFAULT 0,
    rating NUMERIC DEFAULT 0,
    reviews_count INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- حقول الشهادات
    certificate_template JSONB COMMENT 'تصميم قالب الشهادة بصيغة JSON',
    certificate_auto_issue BOOLEAN DEFAULT FALSE,
    certificate_logo_url TEXT,
    certificate_signature_url TEXT,
    certificate_custom_color VARCHAR DEFAULT '#1E3A8A',
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- جدول الوحدات (Modules)
CREATE TABLE IF NOT EXISTS public.modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    title VARCHAR NOT NULL,
    description TEXT,
    order_number INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(course_id, order_number)
);

-- جدول الدروس
CREATE TABLE IF NOT EXISTS public.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES public.modules(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    title VARCHAR NOT NULL,
    description TEXT,
    order_number INTEGER NOT NULL,
    lesson_type VARCHAR CHECK (lesson_type IN ('video', 'text', 'file', 'quiz')),
    video_url TEXT,
    video_duration INTEGER,
    content TEXT,
    is_free BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(module_id, order_number)
);

-- جدول موارد الدروس
CREATE TABLE IF NOT EXISTS public.lesson_resources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    file_name VARCHAR NOT NULL,
    file_url TEXT NOT NULL,
    file_type VARCHAR CHECK (file_type IN ('pdf', 'doc', 'image', 'zip', 'other')),
    file_size INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- جدول التسجيلات
CREATE TABLE IF NOT EXISTS public.enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    enrollment_date TIMESTAMP DEFAULT NOW(),
    completion_percentage INTEGER DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    status VARCHAR DEFAULT 'active' CHECK (status IN ('active', 'completed', 'dropped')),
    last_accessed TIMESTAMP,
    certificate_id UUID,
    completed_at TIMESTAMP,
    UNIQUE(student_id, course_id)
);

-- جدول تقدم الدروس
CREATE TABLE IF NOT EXISTS public.lesson_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    is_completed BOOLEAN DEFAULT FALSE,
    watched_duration INTEGER DEFAULT 0,
    completed_at TIMESTAMP,
    UNIQUE(student_id, lesson_id)
);

-- جدول الامتحانات
CREATE TABLE IF NOT EXISTS public.exams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    module_id UUID REFERENCES public.modules(id) ON DELETE CASCADE COMMENT 'معرف الوحدة - NULL يعني امتحان للكورس بالكامل',
    title VARCHAR NOT NULL,
    description TEXT,
    total_questions INTEGER,
    passing_score INTEGER,
    duration_minutes INTEGER,
    status VARCHAR DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
    allow_retake BOOLEAN DEFAULT TRUE,
    max_attempts INTEGER DEFAULT 3,
    order_number INTEGER DEFAULT 0 COMMENT 'ترتيب الامتحان ضمن الوحدة أو الكورس',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(course_id, COALESCE(module_id, '00000000-0000-0000-0000-000000000000'::uuid), order_number)
);

-- جدول أسئلة الامتحانات
CREATE TABLE IF NOT EXISTS public.exam_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id UUID NOT NULL REFERENCES public.exams(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type VARCHAR CHECK (question_type IN ('multiple_choice', 'true_false', 'essay', 'short_answer')),
    options JSONB,
    correct_answer TEXT,
    points INTEGER DEFAULT 1,
    order_number INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(exam_id, order_number)
);

-- جدول نتائج الامتحانات
CREATE TABLE IF NOT EXISTS public.exam_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id UUID NOT NULL REFERENCES public.exams(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    score INTEGER,
    total_score INTEGER,
    percentage NUMERIC,
    passed BOOLEAN,
    attempt_number INTEGER DEFAULT 1,
    completed_at TIMESTAMP,
    answers JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- جدول الشهادات
CREATE TABLE IF NOT EXISTS public.certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    certificate_number VARCHAR NOT NULL UNIQUE,
    issue_date TIMESTAMP DEFAULT NOW(),
    expiry_date TIMESTAMP,
    template_design JSONB,
    certificate_url TEXT,
    status VARCHAR DEFAULT 'issued' CHECK (status IN ('issued', 'revoked')),
    
    -- حقول التخصيص
    provider_logo_url TEXT COMMENT 'رابط شعار مقدم الخدمة',
    provider_signature_url TEXT COMMENT 'رابط توقيع مقدم الخدمة',
    custom_color VARCHAR DEFAULT '#1E3A8A' COMMENT 'اللون المخصص للشهادة',
    auto_issue BOOLEAN DEFAULT FALSE COMMENT 'هل تم إصدار الشهادة تلقائياً',
    grade VARCHAR COMMENT 'التقدير (A+, A, B+, إلخ)',
    completion_date TIMESTAMP COMMENT 'تاريخ إكمال الكورس',
    
    created_at TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE public.certificates IS 'جدول الشهادات مع دعم الإصدار التلقائي والتخصيص';

-- جدول المدفوعات
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL CHECK (amount >= 0),
    currency VARCHAR DEFAULT 'SAR',
    payment_method VARCHAR CHECK (payment_method IN ('credit_card', 'apple_pay', 'google_pay', 'bank_transfer')),
    transaction_id VARCHAR UNIQUE,
    status VARCHAR DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    payment_date TIMESTAMP,
    receipt_image_url TEXT,
    transaction_reference TEXT,
    student_name TEXT,
    course_name TEXT,
    verified_by UUID REFERENCES public.users(id),
    verified_at TIMESTAMPTZ,
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- جدول الإشعارات
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title VARCHAR NOT NULL,
    message TEXT,
    type VARCHAR CHECK (type IN ('course', 'exam', 'certificate', 'payment', 'system')),
    related_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- جدول التقييمات
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(course_id, student_id)
);

-- جدول إعدادات التطبيق
CREATE TABLE IF NOT EXISTS public.app_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    theme VARCHAR DEFAULT 'light' CHECK (theme IN ('light', 'dark')),
    language VARCHAR DEFAULT 'ar' CHECK (language IN ('ar', 'en')),
    notifications_enabled BOOLEAN DEFAULT TRUE,
    email_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE COMMENT 'تفعيل الإشعارات الفورية',
    notify_new_students BOOLEAN DEFAULT TRUE COMMENT 'إشعار عند انضمام طالب جديد',
    notify_new_reviews BOOLEAN DEFAULT TRUE COMMENT 'إشعار عند تلقي تقييم جديد',
    notify_new_payments BOOLEAN DEFAULT TRUE COMMENT 'إشعار عند تلقي دفعة جديدة',
    auto_save BOOLEAN DEFAULT TRUE COMMENT 'الحفظ التلقائي للتغييرات',
    settings_data JSONB,
    updated_at TIMESTAMP DEFAULT NOW()
);

-- جدول إعدادات الدفع لمقدمي الخدمات
CREATE TABLE IF NOT EXISTS public.provider_payment_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID NOT NULL UNIQUE REFERENCES public.users(id) ON DELETE CASCADE,
    wallet_number TEXT,
    wallet_owner_name TEXT,
    bank_name TEXT,
    bank_account_number TEXT,
    bank_account_owner_name TEXT,
    iban TEXT,
    additional_info TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
COMMENT ON TABLE public.provider_payment_settings IS 'إعدادات الدفع لمقدمي الخدمات';

-- جدول قائمة الانتظار
CREATE TABLE IF NOT EXISTS public.waitlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE,
    user_type TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
    email_sent BOOLEAN DEFAULT FALSE,
    email_sent_at TIMESTAMPTZ
);

-- جدول سجل التدقيق
CREATE TABLE IF NOT EXISTS public.audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    action TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    user_id UUID REFERENCES public.users(id),
    created_at TIMESTAMP DEFAULT NOW()
);


-- ============================================
-- 3. إنشاء الفهارس (Indexes)
-- ============================================

-- فهارس جدول المستخدمين
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON public.users(user_type);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON public.users(is_active);

-- فهارس جدول الكورسات
CREATE INDEX IF NOT EXISTS idx_courses_provider_id ON public.courses(provider_id);
CREATE INDEX IF NOT EXISTS idx_courses_status ON public.courses(status);
CREATE INDEX IF NOT EXISTS idx_courses_category ON public.courses(category);
CREATE INDEX IF NOT EXISTS idx_courses_level ON public.courses(level);
CREATE INDEX IF NOT EXISTS idx_courses_provider_status ON public.courses(provider_id, status);
CREATE INDEX IF NOT EXISTS idx_courses_cover_image_url ON public.courses(cover_image_url) WHERE cover_image_url IS NOT NULL;

-- فهارس جدول الوحدات
CREATE INDEX IF NOT EXISTS idx_modules_course_id ON public.modules(course_id);

-- فهارس جدول الدروس
CREATE INDEX IF NOT EXISTS idx_lessons_module_id ON public.lessons(module_id);
CREATE INDEX IF NOT EXISTS idx_lessons_course_id ON public.lessons(course_id);

-- فهارس جدول موارد الدروس
CREATE INDEX IF NOT EXISTS idx_lesson_resources_lesson_id ON public.lesson_resources(lesson_id);

-- فهارس جدول التسجيلات
CREATE INDEX IF NOT EXISTS idx_enrollments_student_id ON public.enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id ON public.enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_status ON public.enrollments(status);
CREATE INDEX IF NOT EXISTS idx_enrollments_student_course ON public.enrollments(student_id, course_id);

-- فهارس جدول تقدم الدروس
CREATE INDEX IF NOT EXISTS idx_lesson_progress_student_id ON public.lesson_progress(student_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_lesson_id ON public.lesson_progress(lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_student_lesson ON public.lesson_progress(student_id, lesson_id);

-- فهارس جدول الامتحانات
CREATE INDEX IF NOT EXISTS idx_exams_course_id ON public.exams(course_id);
CREATE INDEX IF NOT EXISTS idx_exams_module_id ON public.exams(module_id);
CREATE INDEX IF NOT EXISTS idx_exams_status ON public.exams(status);

-- فهارس جدول أسئلة الامتحانات
CREATE INDEX IF NOT EXISTS idx_exam_questions_exam_id ON public.exam_questions(exam_id);

-- فهارس جدول نتائج الامتحانات
CREATE INDEX IF NOT EXISTS idx_exam_results_exam_id ON public.exam_results(exam_id);
CREATE INDEX IF NOT EXISTS idx_exam_results_student_id ON public.exam_results(student_id);
CREATE INDEX IF NOT EXISTS idx_exam_results_passed ON public.exam_results(passed);

-- فهارس جدول الشهادات
CREATE INDEX IF NOT EXISTS idx_certificates_student_id ON public.certificates(student_id);
CREATE INDEX IF NOT EXISTS idx_certificates_course_id ON public.certificates(course_id);
CREATE INDEX IF NOT EXISTS idx_certificates_provider_id ON public.certificates(provider_id);
CREATE INDEX IF NOT EXISTS idx_certificates_status ON public.certificates(status);
CREATE INDEX IF NOT EXISTS idx_certificates_certificate_number ON public.certificates(certificate_number);
CREATE INDEX IF NOT EXISTS idx_certificates_auto_issue ON public.certificates(auto_issue);

-- فهارس جدول المدفوعات
CREATE INDEX IF NOT EXISTS idx_payments_student_id ON public.payments(student_id);
CREATE INDEX IF NOT EXISTS idx_payments_course_id ON public.payments(course_id);
CREATE INDEX IF NOT EXISTS idx_payments_provider_id ON public.payments(provider_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_student_status ON public.payments(student_id, status);
CREATE INDEX IF NOT EXISTS idx_payments_provider_status ON public.payments(provider_id, status);

-- فهارس جدول الإشعارات
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON public.notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at);

-- فهارس جدول التقييمات
CREATE INDEX IF NOT EXISTS idx_reviews_course_id ON public.reviews(course_id);
CREATE INDEX IF NOT EXISTS idx_reviews_student_id ON public.reviews(student_id);

-- فهارس جدول إعدادات التطبيق
CREATE INDEX IF NOT EXISTS idx_app_settings_user_id ON public.app_settings(user_id);

-- فهارس جدول إعدادات الدفع
CREATE INDEX IF NOT EXISTS idx_provider_payment_settings_provider ON public.provider_payment_settings(provider_id);

-- فهارس جدول قائمة الانتظار
CREATE INDEX IF NOT EXISTS idx_waitlist_email ON public.waitlist(email);
CREATE INDEX IF NOT EXISTS idx_waitlist_created_at ON public.waitlist(created_at DESC);

-- ============================================
-- 4. تفعيل Row Level Security (RLS)
-- ============================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.provider_payment_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.waitlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;


-- ============================================
-- 5. سياسات الأمان (RLS Policies)
-- ============================================

-- سياسات جدول المستخدمين
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Everyone can view providers" ON public.users;
CREATE POLICY "Everyone can view providers" ON public.users FOR SELECT USING (user_type = 'provider' OR auth.uid() = id);

-- سياسات جدول الكورسات
DROP POLICY IF EXISTS "Students can view published courses" ON public.courses;
CREATE POLICY "Students can view published courses" ON public.courses FOR SELECT USING (status = 'published' OR provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can view their courses" ON public.courses;
CREATE POLICY "Providers can view their courses" ON public.courses FOR SELECT USING (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can insert their courses" ON public.courses;
CREATE POLICY "Providers can insert their courses" ON public.courses FOR INSERT WITH CHECK (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can update their courses" ON public.courses;
CREATE POLICY "Providers can update their courses" ON public.courses FOR UPDATE USING (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can delete their courses" ON public.courses;
CREATE POLICY "Providers can delete their courses" ON public.courses FOR DELETE USING (provider_id = auth.uid());

-- سياسات جدول الوحدات
DROP POLICY IF EXISTS "Students can view modules" ON public.modules;
CREATE POLICY "Students can view modules" ON public.modules FOR SELECT USING (
    course_id IN (SELECT id FROM courses WHERE status = 'published') OR
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can view modules" ON public.modules;
CREATE POLICY "Providers can view modules" ON public.modules FOR SELECT USING (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can insert modules" ON public.modules;
CREATE POLICY "Providers can insert modules" ON public.modules FOR INSERT WITH CHECK (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can update modules" ON public.modules;
CREATE POLICY "Providers can update modules" ON public.modules FOR UPDATE USING (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can delete modules" ON public.modules;
CREATE POLICY "Providers can delete modules" ON public.modules FOR DELETE USING (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

-- سياسات جدول الدروس
DROP POLICY IF EXISTS "Students can view lessons" ON public.lessons;
CREATE POLICY "Students can view lessons" ON public.lessons FOR SELECT USING (
    course_id IN (SELECT id FROM courses WHERE status = 'published') OR
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can view lessons" ON public.lessons;
CREATE POLICY "Providers can view lessons" ON public.lessons FOR SELECT USING (
    module_id IN (SELECT m.id FROM modules m JOIN courses c ON m.course_id = c.id WHERE c.provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can insert lessons" ON public.lessons;
CREATE POLICY "Providers can insert lessons" ON public.lessons FOR INSERT WITH CHECK (
    module_id IN (SELECT m.id FROM modules m JOIN courses c ON m.course_id = c.id WHERE c.provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can update lessons" ON public.lessons;
CREATE POLICY "Providers can update lessons" ON public.lessons FOR UPDATE USING (
    module_id IN (SELECT m.id FROM modules m JOIN courses c ON m.course_id = c.id WHERE c.provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can delete lessons" ON public.lessons;
CREATE POLICY "Providers can delete lessons" ON public.lessons FOR DELETE USING (
    module_id IN (SELECT m.id FROM modules m JOIN courses c ON m.course_id = c.id WHERE c.provider_id = auth.uid())
);

-- سياسات جدول موارد الدروس
DROP POLICY IF EXISTS "Students can view lesson resources" ON public.lesson_resources;
CREATE POLICY "Students can view lesson resources" ON public.lesson_resources FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM enrollments e JOIN lessons l ON l.course_id = e.course_id
        WHERE l.id = lesson_id AND e.student_id = auth.uid() AND e.status = 'active'
    ) OR
    EXISTS (
        SELECT 1 FROM lessons l JOIN courses c ON c.id = l.course_id
        WHERE l.id = lesson_id AND c.provider_id = auth.uid()
    )
);

DROP POLICY IF EXISTS "Providers can add lesson resources" ON public.lesson_resources;
CREATE POLICY "Providers can add lesson resources" ON public.lesson_resources FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM lessons l JOIN courses c ON c.id = l.course_id
        WHERE l.id = lesson_id AND c.provider_id = auth.uid()
    )
);

DROP POLICY IF EXISTS "Providers can update lesson resources" ON public.lesson_resources;
CREATE POLICY "Providers can update lesson resources" ON public.lesson_resources FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM lessons l JOIN courses c ON c.id = l.course_id
        WHERE l.id = lesson_id AND c.provider_id = auth.uid()
    )
);

DROP POLICY IF EXISTS "Providers can delete lesson resources" ON public.lesson_resources;
CREATE POLICY "Providers can delete lesson resources" ON public.lesson_resources FOR DELETE USING (
    EXISTS (
        SELECT 1 FROM lessons l JOIN courses c ON c.id = l.course_id
        WHERE l.id = lesson_id AND c.provider_id = auth.uid()
    )
);

-- سياسات جدول التسجيلات
DROP POLICY IF EXISTS "Students can view their enrollments" ON public.enrollments;
CREATE POLICY "Students can view their enrollments" ON public.enrollments FOR SELECT USING (student_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert their own enrollments" ON public.enrollments;
CREATE POLICY "Users can insert their own enrollments" ON public.enrollments FOR INSERT WITH CHECK (
    student_id = auth.uid() AND
    EXISTS (SELECT 1 FROM courses WHERE id = course_id AND status = 'published')
);

DROP POLICY IF EXISTS "Users can update their own enrollments" ON public.enrollments;
CREATE POLICY "Users can update their own enrollments" ON public.enrollments FOR UPDATE USING (student_id = auth.uid()) WITH CHECK (student_id = auth.uid());

DROP POLICY IF EXISTS "Providers can view their students" ON public.enrollments;
CREATE POLICY "Providers can view their students" ON public.enrollments FOR SELECT USING (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can update enrollments" ON public.enrollments;
CREATE POLICY "Providers can update enrollments" ON public.enrollments FOR UPDATE USING (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

-- سياسات جدول تقدم الدروس
DROP POLICY IF EXISTS "Students can view their progress" ON public.lesson_progress;
CREATE POLICY "Students can view their progress" ON public.lesson_progress FOR SELECT USING (student_id = auth.uid());

-- سياسات جدول الامتحانات
DROP POLICY IF EXISTS "Providers can view exams" ON public.exams;
CREATE POLICY "Providers can view exams" ON public.exams FOR SELECT USING (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can insert exams" ON public.exams;
CREATE POLICY "Providers can insert exams" ON public.exams FOR INSERT WITH CHECK (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can update exams" ON public.exams;
CREATE POLICY "Providers can update exams" ON public.exams FOR UPDATE USING (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can delete exams" ON public.exams;
CREATE POLICY "Providers can delete exams" ON public.exams FOR DELETE USING (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

-- سياسات جدول أسئلة الامتحانات
DROP POLICY IF EXISTS "Providers can view exam questions" ON public.exam_questions;
CREATE POLICY "Providers can view exam questions" ON public.exam_questions FOR SELECT USING (
    exam_id IN (SELECT e.id FROM exams e JOIN courses c ON e.course_id = c.id WHERE c.provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can insert exam questions" ON public.exam_questions;
CREATE POLICY "Providers can insert exam questions" ON public.exam_questions FOR INSERT WITH CHECK (
    exam_id IN (SELECT e.id FROM exams e JOIN courses c ON e.course_id = c.id WHERE c.provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can update exam questions" ON public.exam_questions;
CREATE POLICY "Providers can update exam questions" ON public.exam_questions FOR UPDATE USING (
    exam_id IN (SELECT e.id FROM exams e JOIN courses c ON e.course_id = c.id WHERE c.provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can delete exam questions" ON public.exam_questions;
CREATE POLICY "Providers can delete exam questions" ON public.exam_questions FOR DELETE USING (
    exam_id IN (SELECT e.id FROM exams e JOIN courses c ON e.course_id = c.id WHERE c.provider_id = auth.uid())
);

-- سياسات جدول نتائج الامتحانات
DROP POLICY IF EXISTS "Students can view their exam results" ON public.exam_results;
CREATE POLICY "Students can view their exam results" ON public.exam_results FOR SELECT USING (student_id = auth.uid());

DROP POLICY IF EXISTS "Providers can view exam results for their courses" ON public.exam_results;
CREATE POLICY "Providers can view exam results for their courses" ON public.exam_results FOR SELECT USING (
    exam_id IN (SELECT id FROM exams WHERE course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()))
);

-- سياسات جدول الشهادات
DROP POLICY IF EXISTS "Students can view their certificates" ON public.certificates;
CREATE POLICY "Students can view their certificates" ON public.certificates FOR SELECT USING (student_id = auth.uid());

DROP POLICY IF EXISTS "Providers can view certificates" ON public.certificates;
CREATE POLICY "Providers can view certificates" ON public.certificates FOR SELECT USING (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can insert certificates" ON public.certificates;
CREATE POLICY "Providers can insert certificates" ON public.certificates FOR INSERT WITH CHECK (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can update certificates" ON public.certificates;
CREATE POLICY "Providers can update certificates" ON public.certificates FOR UPDATE USING (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

-- سياسات جدول المدفوعات
DROP POLICY IF EXISTS "Students can view own payments" ON public.payments;
CREATE POLICY "Students can view own payments" ON public.payments FOR SELECT USING (
    student_id = auth.uid() OR provider_id = auth.uid() OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND user_type = 'admin')
);

DROP POLICY IF EXISTS "Providers can view payments" ON public.payments;
CREATE POLICY "Providers can view payments" ON public.payments FOR SELECT USING (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

DROP POLICY IF EXISTS "Providers can update payments" ON public.payments;
CREATE POLICY "Providers can update payments" ON public.payments FOR UPDATE USING (
    course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())
);

-- سياسات جدول الإشعارات
DROP POLICY IF EXISTS "Students can view their notifications" ON public.notifications;
CREATE POLICY "Students can view their notifications" ON public.notifications FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert notifications" ON public.notifications;
CREATE POLICY "Users can insert notifications" ON public.notifications FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update their notifications" ON public.notifications;
CREATE POLICY "Users can update their notifications" ON public.notifications FOR UPDATE USING (user_id = auth.uid());

-- سياسات جدول التقييمات
DROP POLICY IF EXISTS "Students can view all reviews" ON public.reviews;
CREATE POLICY "Students can view all reviews" ON public.reviews FOR SELECT USING (true);

DROP POLICY IF EXISTS "Students can add reviews" ON public.reviews;
CREATE POLICY "Students can add reviews" ON public.reviews FOR INSERT WITH CHECK (
    auth.uid() = student_id AND
    EXISTS (
        SELECT 1 FROM enrollments
        WHERE student_id = auth.uid() AND course_id = reviews.course_id AND status IN ('active', 'completed')
    )
);

DROP POLICY IF EXISTS "Students can update own reviews" ON public.reviews;
CREATE POLICY "Students can update own reviews" ON public.reviews FOR UPDATE USING (auth.uid() = student_id);

DROP POLICY IF EXISTS "Students can delete own reviews" ON public.reviews;
CREATE POLICY "Students can delete own reviews" ON public.reviews FOR DELETE USING (
    auth.uid() = student_id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND user_type = 'admin')
);

-- سياسات جدول إعدادات التطبيق
DROP POLICY IF EXISTS "Users can view their settings" ON public.app_settings;
CREATE POLICY "Users can view their settings" ON public.app_settings FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert their settings" ON public.app_settings;
CREATE POLICY "Users can insert their settings" ON public.app_settings FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update their settings" ON public.app_settings;
CREATE POLICY "Users can update their settings" ON public.app_settings FOR UPDATE USING (user_id = auth.uid());

-- سياسات جدول إعدادات الدفع
DROP POLICY IF EXISTS "Providers can view their payment settings" ON public.provider_payment_settings;
CREATE POLICY "Providers can view their payment settings" ON public.provider_payment_settings FOR SELECT USING (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can insert their payment settings" ON public.provider_payment_settings;
CREATE POLICY "Providers can insert their payment settings" ON public.provider_payment_settings FOR INSERT WITH CHECK (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can update their payment settings" ON public.provider_payment_settings;
CREATE POLICY "Providers can update their payment settings" ON public.provider_payment_settings FOR UPDATE USING (provider_id = auth.uid());

-- سياسات جدول قائمة الانتظار
DROP POLICY IF EXISTS "Anyone can join waitlist" ON public.waitlist;
CREATE POLICY "Anyone can join waitlist" ON public.waitlist FOR INSERT WITH CHECK (
    email IS NOT NULL AND email <> '' AND email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
);

DROP POLICY IF EXISTS "Only admins can view waitlist" ON public.waitlist;
CREATE POLICY "Only admins can view waitlist" ON public.waitlist FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND user_type = 'admin')
);

DROP POLICY IF EXISTS "Only admins can update waitlist" ON public.waitlist;
CREATE POLICY "Only admins can update waitlist" ON public.waitlist FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND user_type = 'admin')
);

DROP POLICY IF EXISTS "Only admins can delete waitlist" ON public.waitlist;
CREATE POLICY "Only admins can delete waitlist" ON public.waitlist FOR DELETE USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND user_type = 'admin')
);

-- سياسات جدول سجل التدقيق
DROP POLICY IF EXISTS "Only admins can view audit log" ON public.audit_log;
CREATE POLICY "Only admins can view audit log" ON public.audit_log FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND user_type = 'admin')
);


-- ============================================
-- 6. الدوال (Functions)
-- ============================================

-- دالة معالجة المستخدم الجديد
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_user_type TEXT;
  v_name      TEXT;
  v_phone     TEXT;
BEGIN
  v_user_type := COALESCE(NEW.raw_user_meta_data->>'user_type', 'provider');
  v_name      := COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1));
  v_phone     := NEW.raw_user_meta_data->>'phone';

  IF v_user_type NOT IN ('student', 'provider', 'admin') THEN
    v_user_type := 'provider';
  END IF;

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
$$;

-- دالة تحديث عدد الطلاب في الكورس
CREATE OR REPLACE FUNCTION public.update_course_students_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO 'public', 'pg_temp'
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE courses SET students_count = students_count + 1 WHERE id = NEW.course_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE courses SET students_count = students_count - 1 WHERE id = OLD.course_id;
  END IF;
  RETURN NULL;
END;
$$;

-- دالة تحديث عدد الكورسات لمقدم الخدمة
CREATE OR REPLACE FUNCTION public.update_provider_courses_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO 'public', 'pg_temp'
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE users SET courses_count = courses_count + 1 WHERE id = NEW.provider_id AND user_type = 'provider';
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE users SET courses_count = courses_count - 1 WHERE id = OLD.provider_id AND user_type = 'provider';
  END IF;
  RETURN NULL;
END;
$$;

-- دالة تحديث تاريخ إكمال التسجيل
CREATE OR REPLACE FUNCTION public.update_enrollment_completed_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO 'public', 'pg_temp'
AS $$
BEGIN
  IF NEW.completion_percentage = 100 AND (OLD.completion_percentage < 100 OR OLD.completed_at IS NULL) THEN
    NEW.completed_at := NOW();
  END IF;
  RETURN NEW;
END;
$$;

-- دالة التحقق من أهلية الطالب للحصول على الشهادة
CREATE OR REPLACE FUNCTION public.check_student_eligibility(p_student_id UUID, p_course_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SET search_path TO 'public', 'pg_temp'
AS $$
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
$$;

-- دالة الحصول على الطلاب المؤهلين للشهادة
CREATE OR REPLACE FUNCTION public.get_eligible_students(p_course_id UUID)
RETURNS TABLE(
  student_id UUID,
  student_name TEXT,
  student_email TEXT,
  progress INTEGER,
  exam_score INTEGER,
  completion_date TIMESTAMP
)
LANGUAGE plpgsql
SET search_path TO 'public', 'pg_temp'
AS $$
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
$$;

-- دالة الإصدار التلقائي للشهادة
CREATE OR REPLACE FUNCTION public.auto_issue_certificate()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO 'public', 'pg_temp'
AS $$
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
$$;

-- دالة تحديث حالة الدفع
CREATE OR REPLACE FUNCTION public.update_payment_status(
  p_payment_id UUID,
  p_new_status TEXT,
  p_verified_by UUID,
  p_rejection_reason TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SET search_path TO 'public', 'pg_temp'
AS $$
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
    rejection_reason = p_rejection_reason
  WHERE id = p_payment_id;
  
  -- إذا تم تأكيد الدفع، تفعيل وصول الطالب للكورس
  IF p_new_status = 'completed' THEN
    -- التحقق من وجود تسجيل
    IF EXISTS (SELECT 1 FROM enrollments WHERE student_id = v_student_id AND course_id = v_course_id) THEN
      -- تحديث التسجيل الموجود
      UPDATE enrollments
      SET 
        status = 'active',
        updated_at = NOW()
      WHERE student_id = v_student_id AND course_id = v_course_id;
    ELSE
      -- إنشاء تسجيل جديد
      INSERT INTO enrollments (
        student_id,
        course_id,
        enrollment_date,
        status,
        completion_percentage
      ) VALUES (
        v_student_id,
        v_course_id,
        NOW(),
        'active',
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
$$;

-- دالة تحديث وقت التعديل لإعدادات الدفع
CREATE OR REPLACE FUNCTION public.update_provider_payment_settings_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO 'public', 'pg_temp'
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- دالة التحقق من صلاحيات المستخدم
CREATE OR REPLACE FUNCTION public.check_user_permission(required_permission TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $$
DECLARE
  user_permissions JSONB;
BEGIN
  -- الحصول على صلاحيات المستخدم
  SELECT permissions INTO user_permissions
  FROM users
  WHERE id = auth.uid();
  
  -- التحقق من وجود الصلاحية
  IF user_permissions IS NULL THEN
    RETURN FALSE;
  END IF;
  
  RETURN user_permissions ? required_permission;
END;
$$;

-- دالة تفعيل RLS تلقائياً
CREATE OR REPLACE FUNCTION public.rls_auto_enable()
RETURNS EVENT_TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog'
AS $$
DECLARE
  cmd RECORD;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('ALTER TABLE IF EXISTS %s ENABLE ROW LEVEL SECURITY', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$$;


-- ============================================
-- 7. التريجرز (Triggers)
-- ============================================

-- تريجر معالجة المستخدم الجديد
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- تريجر تحديث عدد الطلاب في الكورس
DROP TRIGGER IF EXISTS trigger_update_course_students_count ON public.enrollments;
CREATE TRIGGER trigger_update_course_students_count
  AFTER INSERT OR DELETE ON public.enrollments
  FOR EACH ROW
  EXECUTE FUNCTION public.update_course_students_count();

-- تريجر تحديث عدد الكورسات لمقدم الخدمة
DROP TRIGGER IF EXISTS trigger_update_provider_courses_count ON public.courses;
CREATE TRIGGER trigger_update_provider_courses_count
  AFTER INSERT OR DELETE ON public.courses
  FOR EACH ROW
  EXECUTE FUNCTION public.update_provider_courses_count();

-- تريجر تحديث تاريخ إكمال التسجيل
DROP TRIGGER IF EXISTS trigger_update_completed_at ON public.enrollments;
CREATE TRIGGER trigger_update_completed_at
  BEFORE UPDATE ON public.enrollments
  FOR EACH ROW
  EXECUTE FUNCTION public.update_enrollment_completed_at();

-- تريجر الإصدار التلقائي للشهادة
DROP TRIGGER IF EXISTS trigger_auto_issue_certificate ON public.enrollments;
CREATE TRIGGER trigger_auto_issue_certificate
  AFTER UPDATE ON public.enrollments
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_issue_certificate();

-- تريجر تحديث وقت التعديل لإعدادات الدفع
DROP TRIGGER IF EXISTS trigger_update_provider_payment_settings_updated_at ON public.provider_payment_settings;
CREATE TRIGGER trigger_update_provider_payment_settings_updated_at
  BEFORE UPDATE ON public.provider_payment_settings
  FOR EACH ROW
  EXECUTE FUNCTION public.update_provider_payment_settings_updated_at();

-- تريجر تفعيل RLS تلقائياً
DROP EVENT TRIGGER IF EXISTS rls_auto_enable_trigger;
CREATE EVENT TRIGGER rls_auto_enable_trigger
  ON ddl_command_end
  WHEN TAG IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
  EXECUTE FUNCTION public.rls_auto_enable();

-- ============================================
-- 8. Storage Buckets
-- ============================================

-- إنشاء Buckets للتخزين
INSERT INTO storage.buckets (id, name, public) 
VALUES 
  ('avatars', 'avatars', true),
  ('certificates', 'certificates', true),
  ('course-videos', 'course-videos', true),
  ('course-images', 'course-images', true),
  ('course-files', 'course-files', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 9. Storage Policies
-- ============================================

-- سياسات bucket الصور الشخصية (avatars)
DROP POLICY IF EXISTS "Avatar images are publicly accessible" ON storage.objects;
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

DROP POLICY IF EXISTS "Users can delete their own avatar" ON storage.objects;
CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- سياسات bucket الشهادات (certificates)
DROP POLICY IF EXISTS "Certificates are publicly accessible" ON storage.objects;
CREATE POLICY "Certificates are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'certificates');

DROP POLICY IF EXISTS "Providers can upload certificates" ON storage.objects;
CREATE POLICY "Providers can upload certificates"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'certificates' AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type IN ('provider', 'admin')
  )
);

DROP POLICY IF EXISTS "Providers can update certificates" ON storage.objects;
CREATE POLICY "Providers can update certificates"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'certificates' AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type IN ('provider', 'admin')
  )
);

DROP POLICY IF EXISTS "Providers can delete certificates" ON storage.objects;
CREATE POLICY "Providers can delete certificates"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'certificates' AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type IN ('provider', 'admin')
  )
);

-- سياسات bucket فيديوهات الكورسات (course-videos)
DROP POLICY IF EXISTS "Course videos are publicly accessible" ON storage.objects;
CREATE POLICY "Course videos are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'course-videos');

DROP POLICY IF EXISTS "Providers can upload course videos" ON storage.objects;
CREATE POLICY "Providers can upload course videos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'course-videos' AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type IN ('provider', 'admin')
  )
);

DROP POLICY IF EXISTS "Providers can update course videos" ON storage.objects;
CREATE POLICY "Providers can update course videos"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'course-videos' AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type IN ('provider', 'admin')
  )
);

DROP POLICY IF EXISTS "Providers can delete course videos" ON storage.objects;
CREATE POLICY "Providers can delete course videos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'course-videos' AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type IN ('provider', 'admin')
  )
);

-- سياسات bucket صور الكورسات (course-images)
DROP POLICY IF EXISTS "Course images are publicly accessible" ON storage.objects;
CREATE POLICY "Course images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'course-images');

DROP POLICY IF EXISTS "Providers can upload course images" ON storage.objects;
CREATE POLICY "Providers can upload course images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'course-images' AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type IN ('provider', 'admin')
  )
);

DROP POLICY IF EXISTS "Providers can update course images" ON storage.objects;
CREATE POLICY "Providers can update course images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'course-images' AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type IN ('provider', 'admin')
  )
);

DROP POLICY IF EXISTS "Providers can delete course images" ON storage.objects;
CREATE POLICY "Providers can delete course images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'course-images' AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type IN ('provider', 'admin')
  )
);

-- سياسات bucket ملفات الكورسات (course-files)
DROP POLICY IF EXISTS "Course files are publicly accessible" ON storage.objects;
CREATE POLICY "Course files are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'course-files');

DROP POLICY IF EXISTS "Providers can upload course files" ON storage.objects;
CREATE POLICY "Providers can upload course files"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'course-files' AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type IN ('provider', 'admin')
  )
);

DROP POLICY IF EXISTS "Providers can update course files" ON storage.objects;
CREATE POLICY "Providers can update course files"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'course-files' AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type IN ('provider', 'admin')
  )
);

DROP POLICY IF EXISTS "Providers can delete course files" ON storage.objects;
CREATE POLICY "Providers can delete course files"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'course-files' AND
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type IN ('provider', 'admin')
  )
);

-- ============================================
-- 10. ملاحظات مهمة
-- ============================================

/*
ملاحظات الاستخدام:
-----------------

1. قبل تشغيل هذا الملف، تأكد من:
   - إنشاء مشروع Supabase جديد
   - الحصول على معلومات الاتصال (URL و API Keys)

2. لتشغيل هذا الملف:
   - يمكنك استخدام Supabase Dashboard > SQL Editor
   - أو استخدام Supabase CLI: supabase db push

3. بعد تشغيل الملف:
   - تحقق من إنشاء جميع الجداول
   - تحقق من تفعيل RLS على جميع الجداول
   - تحقق من إنشاء Storage Buckets

4. الإعدادات المطلوبة في التطبيق:
   - SUPABASE_URL: رابط مشروع Supabase
   - SUPABASE_ANON_KEY: المفتاح العام (anon key)

5. الأمان:
   - جميع الجداول محمية بـ RLS
   - Storage Buckets محمية بسياسات الوصول
   - الدوال محمية بـ SECURITY DEFINER

6. النسخ الاحتياطي:
   - احتفظ بنسخة من هذا الملف في مكان آمن
   - قم بعمل نسخ احتياطية دورية من قاعدة البيانات

7. التحديثات المستقبلية:
   - عند إضافة جداول جديدة، أضفها لهذا الملف
   - عند تعديل السياسات، حدّث هذا الملف
   - احتفظ بسجل للتغييرات (changelog)

8. استعادة قاعدة البيانات:
   - في حالة فقدان البيانات، قم بإنشاء مشروع جديد
   - شغّل هذا الملف بالكامل
   - استعد البيانات من النسخة الاحتياطية

9. الدعم الفني:
   - للمساعدة: https://supabase.com/docs
   - المجتمع: https://github.com/supabase/supabase/discussions

10. معلومات المشروع:
    - اسم المشروع: Wasla Academy
    - النسخة: 1.0.0
    - تاريخ الإنشاء: 2026-04-13
    - المطور: Wasla Academy Team
*/

-- ============================================
-- نهاية الملف
-- ============================================

-- تم إنشاء هذا الملف بنجاح!
-- يحتوي على كامل بنية قاعدة بيانات Wasla Academy
-- بما في ذلك: الجداول، الفهارس، السياسات، الدوال، التريجرز، و Storage Buckets

SELECT 'Database backup file created successfully!' AS status;
