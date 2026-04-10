-- التأكد من وجود عمود cover_image_url في جدول courses
-- يمكن تشغيل هذا السكريبت بأمان عدة مرات

-- إضافة عمود cover_image_url إذا لم يكن موجوداً
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'courses' 
        AND column_name = 'cover_image_url'
    ) THEN
        ALTER TABLE courses 
        ADD COLUMN cover_image_url TEXT;
        
        RAISE NOTICE 'تم إضافة عمود cover_image_url';
    ELSE
        RAISE NOTICE 'عمود cover_image_url موجود بالفعل';
    END IF;
END $$;

-- إضافة تعليق على العمود
COMMENT ON COLUMN courses.cover_image_url IS 'رابط الصورة التعريفية (الغلاف) للكورس';

-- إنشاء index للبحث السريع (اختياري)
CREATE INDEX IF NOT EXISTS idx_courses_cover_image_url 
ON courses(cover_image_url) 
WHERE cover_image_url IS NOT NULL;

COMMENT ON INDEX idx_courses_cover_image_url IS 'فهرس للكورسات التي تحتوي على صورة غلاف';
