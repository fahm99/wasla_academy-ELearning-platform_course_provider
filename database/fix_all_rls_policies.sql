-- ============================================
-- إصلاح شامل لجميع سياسات RLS المفقودة
-- ============================================

-- ============================================
-- 1. جدول الكورسات (courses)
-- ============================================

-- سياسة INSERT للمقدمين
DROP POLICY IF EXISTS "Providers can insert their courses" ON courses;
CREATE POLICY "Providers can insert their courses"
  ON courses FOR INSERT
  WITH CHECK (provider_id = auth.uid());

-- ============================================
-- 2. جدول الوحدات (modules)
-- ============================================

DROP POLICY IF EXISTS "Providers can insert modules" ON modules;
CREATE POLICY "Providers can insert modules"
  ON modules FOR INSERT
  WITH CHECK (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can update modules" ON modules;
CREATE POLICY "Providers can update modules"
  ON modules FOR UPDATE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can delete modules" ON modules;
CREATE POLICY "Providers can delete modules"
  ON modules FOR DELETE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can view modules" ON modules;
CREATE POLICY "Providers can view modules"
  ON modules FOR SELECT
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

-- ============================================
-- 3. جدول الدروس (lessons)
-- ============================================

DROP POLICY IF EXISTS "Providers can insert lessons" ON lessons;
CREATE POLICY "Providers can insert lessons"
  ON lessons FOR INSERT
  WITH CHECK (module_id IN (
    SELECT m.id FROM modules m 
    JOIN courses c ON m.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Providers can update lessons" ON lessons;
CREATE POLICY "Providers can update lessons"
  ON lessons FOR UPDATE
  USING (module_id IN (
    SELECT m.id FROM modules m 
    JOIN courses c ON m.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Providers can delete lessons" ON lessons;
CREATE POLICY "Providers can delete lessons"
  ON lessons FOR DELETE
  USING (module_id IN (
    SELECT m.id FROM modules m 
    JOIN courses c ON m.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Providers can view lessons" ON lessons;
CREATE POLICY "Providers can view lessons"
  ON lessons FOR SELECT
  USING (module_id IN (
    SELECT m.id FROM modules m 
    JOIN courses c ON m.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

-- ============================================
-- 4. جدول الامتحانات (exams)
-- ============================================

DROP POLICY IF EXISTS "Providers can insert exams" ON exams;
CREATE POLICY "Providers can insert exams"
  ON exams FOR INSERT
  WITH CHECK (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can update exams" ON exams;
CREATE POLICY "Providers can update exams"
  ON exams FOR UPDATE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can delete exams" ON exams;
CREATE POLICY "Providers can delete exams"
  ON exams FOR DELETE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can view exams" ON exams;
CREATE POLICY "Providers can view exams"
  ON exams FOR SELECT
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

-- ============================================
-- 5. جدول أسئلة الامتحانات (exam_questions)
-- ============================================

DROP POLICY IF EXISTS "Providers can insert exam questions" ON exam_questions;
CREATE POLICY "Providers can insert exam questions"
  ON exam_questions FOR INSERT
  WITH CHECK (exam_id IN (
    SELECT e.id FROM exams e 
    JOIN courses c ON e.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Providers can update exam questions" ON exam_questions;
CREATE POLICY "Providers can update exam questions"
  ON exam_questions FOR UPDATE
  USING (exam_id IN (
    SELECT e.id FROM exams e 
    JOIN courses c ON e.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Providers can delete exam questions" ON exam_questions;
CREATE POLICY "Providers can delete exam questions"
  ON exam_questions FOR DELETE
  USING (exam_id IN (
    SELECT e.id FROM exams e 
    JOIN courses c ON e.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Providers can view exam questions" ON exam_questions;
CREATE POLICY "Providers can view exam questions"
  ON exam_questions FOR SELECT
  USING (exam_id IN (
    SELECT e.id FROM exams e 
    JOIN courses c ON e.course_id = c.id 
    WHERE c.provider_id = auth.uid()
  ));

-- ============================================
-- 6. جدول الشهادات (certificates)
-- ============================================

DROP POLICY IF EXISTS "Providers can insert certificates" ON certificates;
CREATE POLICY "Providers can insert certificates"
  ON certificates FOR INSERT
  WITH CHECK (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can update certificates" ON certificates;
CREATE POLICY "Providers can update certificates"
  ON certificates FOR UPDATE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can view certificates" ON certificates;
CREATE POLICY "Providers can view certificates"
  ON certificates FOR SELECT
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

-- ============================================
-- 7. جدول المدفوعات (payments)
-- ============================================

DROP POLICY IF EXISTS "Providers can view payments" ON payments;
CREATE POLICY "Providers can view payments"
  ON payments FOR SELECT
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

DROP POLICY IF EXISTS "Providers can update payments" ON payments;
CREATE POLICY "Providers can update payments"
  ON payments FOR UPDATE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

-- ============================================
-- 8. جدول إعدادات الدفع (provider_payment_settings)
-- ============================================

DROP POLICY IF EXISTS "Providers can view their payment settings" ON provider_payment_settings;
CREATE POLICY "Providers can view their payment settings"
  ON provider_payment_settings FOR SELECT
  USING (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can insert their payment settings" ON provider_payment_settings;
CREATE POLICY "Providers can insert their payment settings"
  ON provider_payment_settings FOR INSERT
  WITH CHECK (provider_id = auth.uid());

DROP POLICY IF EXISTS "Providers can update their payment settings" ON provider_payment_settings;
CREATE POLICY "Providers can update their payment settings"
  ON provider_payment_settings FOR UPDATE
  USING (provider_id = auth.uid());

-- ============================================
-- 9. جدول الإشعارات (notifications)
-- ============================================

DROP POLICY IF EXISTS "Users can insert notifications" ON notifications;
CREATE POLICY "Users can insert notifications"
  ON notifications FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update their notifications" ON notifications;
CREATE POLICY "Users can update their notifications"
  ON notifications FOR UPDATE
  USING (user_id = auth.uid());

-- ============================================
-- 10. جدول الإعدادات (app_settings)
-- ============================================

DROP POLICY IF EXISTS "Users can view their settings" ON app_settings;
CREATE POLICY "Users can view their settings"
  ON app_settings FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert their settings" ON app_settings;
CREATE POLICY "Users can insert their settings"
  ON app_settings FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update their settings" ON app_settings;
CREATE POLICY "Users can update their settings"
  ON app_settings FOR UPDATE
  USING (user_id = auth.uid());

-- ============================================
-- 11. جدول التسجيلات (enrollments)
-- ============================================

DROP POLICY IF EXISTS "Providers can update enrollments" ON enrollments;
CREATE POLICY "Providers can update enrollments"
  ON enrollments FOR UPDATE
  USING (course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()));

COMMENT ON POLICY "Providers can insert their courses" ON courses IS 'يسمح لمقدمي الخدمات بإنشاء كورسات جديدة';
COMMENT ON POLICY "Providers can insert modules" ON modules IS 'يسمح لمقدمي الخدمات بإضافة وحدات لكورساتهم';
COMMENT ON POLICY "Providers can insert lessons" ON lessons IS 'يسمح لمقدمي الخدمات بإضافة دروس لوحداتهم';
COMMENT ON POLICY "Providers can insert exams" ON exams IS 'يسمح لمقدمي الخدمات بإنشاء امتحانات لكورساتهم';
COMMENT ON POLICY "Providers can insert certificates" ON certificates IS 'يسمح لمقدمي الخدمات بإصدار شهادات لطلابهم';
