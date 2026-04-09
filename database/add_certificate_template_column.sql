-- إضافة عمود certificate_template لجدول courses
-- نفذ هذا في Supabase SQL Editor

ALTER TABLE courses 
ADD COLUMN IF NOT EXISTS certificate_template JSONB;

-- إضافة تعليق على العمود
COMMENT ON COLUMN courses.certificate_template IS 'تصميم قالب الشهادة بصيغة JSON';
