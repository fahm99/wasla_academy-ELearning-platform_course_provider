-- ============================================
-- إنشاء Storage Buckets لرفع الملفات
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
-- RLS Policies للـ Storage Buckets
-- ============================================

-- ============================================
-- 1. Policies لـ course-videos
-- ============================================

-- السماح للمقدمين برفع الفيديوهات
CREATE POLICY "Providers can upload videos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'course-videos' AND
  auth.uid() IN (
    SELECT id FROM users WHERE user_type = 'provider'
  )
);

-- السماح للمقدمين بتحديث الفيديوهات الخاصة بهم
CREATE POLICY "Providers can update their videos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'course-videos' AND
  auth.uid() IN (
    SELECT id FROM users WHERE user_type = 'provider'
  )
);

-- السماح للمقدمين بحذف الفيديوهات الخاصة بهم
CREATE POLICY "Providers can delete their videos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'course-videos' AND
  auth.uid() IN (
    SELECT id FROM users WHERE user_type = 'provider'
  )
);

-- السماح للجميع بقراءة الفيديوهات
CREATE POLICY "Anyone can view videos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'course-videos');

-- ============================================
-- 2. Policies لـ course-files
-- ============================================

-- السماح للمقدمين برفع الملفات
CREATE POLICY "Providers can upload files"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'course-files' AND
  auth.uid() IN (
    SELECT id FROM users WHERE user_type = 'provider'
  )
);

-- السماح للمقدمين بتحديث الملفات الخاصة بهم
CREATE POLICY "Providers can update their files"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'course-files' AND
  auth.uid() IN (
    SELECT id FROM users WHERE user_type = 'provider'
  )
);

-- السماح للمقدمين بحذف الملفات الخاصة بهم
CREATE POLICY "Providers can delete their files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'course-files' AND
  auth.uid() IN (
    SELECT id FROM users WHERE user_type = 'provider'
  )
);

-- السماح للجميع بقراءة الملفات
CREATE POLICY "Anyone can view files"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'course-files');

-- ============================================
-- 3. Policies لـ course-images
-- ============================================

-- السماح للمقدمين برفع الصور
CREATE POLICY "Providers can upload images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'course-images' AND
  auth.uid() IN (
    SELECT id FROM users WHERE user_type = 'provider'
  )
);

-- السماح للمقدمين بتحديث الصور الخاصة بهم
CREATE POLICY "Providers can update their images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'course-images' AND
  auth.uid() IN (
    SELECT id FROM users WHERE user_type = 'provider'
  )
);

-- السماح للمقدمين بحذف الصور الخاصة بهم
CREATE POLICY "Providers can delete their images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'course-images' AND
  auth.uid() IN (
    SELECT id FROM users WHERE user_type = 'provider'
  )
);

-- السماح للجميع بقراءة الصور
CREATE POLICY "Anyone can view images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'course-images');

-- ============================================
-- 4. Policies لـ certificates
-- ============================================

-- السماح للمقدمين برفع الشهادات
CREATE POLICY "Providers can upload certificates"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'certificates' AND
  auth.uid() IN (
    SELECT id FROM users WHERE user_type = 'provider'
  )
);

-- السماح للمستخدمين بقراءة شهاداتهم فقط
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
-- 5. Policies لـ avatars
-- ============================================

-- السماح للمستخدمين برفع صورهم الشخصية
CREATE POLICY "Users can upload their avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'profiles' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

-- السماح للمستخدمين بتحديث صورهم الشخصية
CREATE POLICY "Users can update their avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'profiles' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

-- السماح للمستخدمين بحذف صورهم الشخصية
CREATE POLICY "Users can delete their avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'profiles' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

-- السماح للجميع بقراءة الصور الشخصية
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- ============================================
-- ملاحظات مهمة:
-- ============================================
-- 1. تأكد من تشغيل هذا السكريبت في Supabase SQL Editor
-- 2. تأكد من تفعيل RLS على جدول storage.objects
-- 3. يمكنك تعديل الـ policies حسب احتياجاتك
-- 4. الـ buckets العامة (public: true) تسمح بالوصول المباشر للملفات
-- 5. الـ buckets الخاصة (public: false) تحتاج signed URLs للوصول
