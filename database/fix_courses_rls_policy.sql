-- ============================================
-- إصلاح سياسات RLS لجدول الكورسات
-- ============================================

-- إضافة سياسة INSERT المفقودة لمقدمي الخدمات
CREATE POLICY "Providers can insert their courses"
  ON courses FOR INSERT
  WITH CHECK (provider_id = auth.uid());

-- التأكد من أن جميع السياسات موجودة
-- سياسة SELECT
DROP POLICY IF EXISTS "Providers can view their courses" ON courses;
CREATE POLICY "Providers can view their courses"
  ON courses FOR SELECT
  USING (provider_id = auth.uid());

-- سياسة UPDATE
DROP POLICY IF EXISTS "Providers can update their courses" ON courses;
CREATE POLICY "Providers can update their courses"
  ON courses FOR UPDATE
  USING (provider_id = auth.uid());

-- سياسة DELETE
DROP POLICY IF EXISTS "Providers can delete their courses" ON courses;
CREATE POLICY "Providers can delete their courses"
  ON courses FOR DELETE
  USING (provider_id = auth.uid());

-- سياسة للطلاب لرؤية الكورسات المنشورة
DROP POLICY IF EXISTS "Students can view published courses" ON courses;
CREATE POLICY "Students can view published courses"
  ON courses FOR SELECT
  USING (status = 'published' OR provider_id = auth.uid());

COMMENT ON POLICY "Providers can insert their courses" ON courses IS 'يسمح لمقدمي الخدمات بإنشاء كورسات جديدة';
