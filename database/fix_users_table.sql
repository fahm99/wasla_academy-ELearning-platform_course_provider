-- ============================================
-- إصلاح جدول users - نفّذ في Supabase SQL Editor
-- ============================================

-- الخطوة 1: حذف عمود password_hash (Supabase يتولى كلمة المرور في auth.users)
ALTER TABLE public.users
  DROP COLUMN IF EXISTS password_hash;

-- الخطوة 2: إعادة إنشاء الـ trigger بعد إصلاح الجدول
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- الخطوة 3: سياسات RLS
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
CREATE POLICY "Users can view own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
CREATE POLICY "Users can insert own profile"
  ON public.users FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);
