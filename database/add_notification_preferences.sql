-- ============================================
-- إضافة حقول تفضيلات الإشعارات المحددة
-- ============================================

-- إضافة حقول الإشعارات المحددة
ALTER TABLE app_settings 
ADD COLUMN IF NOT EXISTS push_notifications BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS notify_new_students BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS notify_new_reviews BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS notify_new_payments BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS auto_save BOOLEAN DEFAULT TRUE;

-- تحديث السجلات الموجودة
UPDATE app_settings 
SET 
  push_notifications = TRUE,
  notify_new_students = TRUE,
  notify_new_reviews = TRUE,
  notify_new_payments = TRUE,
  auto_save = TRUE
WHERE push_notifications IS NULL;

COMMENT ON COLUMN app_settings.push_notifications IS 'تفعيل الإشعارات الفورية';
COMMENT ON COLUMN app_settings.notify_new_students IS 'إشعار عند انضمام طالب جديد';
COMMENT ON COLUMN app_settings.notify_new_reviews IS 'إشعار عند تلقي تقييم جديد';
COMMENT ON COLUMN app_settings.notify_new_payments IS 'إشعار عند تلقي دفعة جديدة';
COMMENT ON COLUMN app_settings.auto_save IS 'الحفظ التلقائي للتغييرات';
