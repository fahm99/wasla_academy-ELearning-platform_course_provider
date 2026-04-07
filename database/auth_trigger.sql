-- ============================================
-- Trigger: إنشاء سجل في جدول users تلقائياً
-- عند تسجيل أي مستخدم جديد في Supabase Auth
-- يدعم جميع الأنواع: student, provider, admin
-- ============================================
-- قم بتنفيذ هذا الـ SQL في Supabase SQL Editor
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
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
    id,
    email,
    name,
    phone,
    user_type,
    is_verified,
    is_active,
    -- حقول الطالب
    courses_enrolled,
    certificates_count,
    total_spent,
    -- حقول مقدم الخدمة
    courses_count,
    students_count,
    total_earnings,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    v_name,
    v_phone,
    v_user_type,
    FALSE,
    TRUE,
    -- قيم افتراضية للطالب
    0,
    0,
    0,
    -- قيم افتراضية لمقدم الخدمة
    0,
    0,
    0,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

-- ربط الدالة بـ trigger على جدول auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- منح الصلاحيات اللازمة
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.users TO postgres, service_role;
