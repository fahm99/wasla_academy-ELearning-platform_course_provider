# تحديث نظام الشهادات

## الخطوات المطلوبة

### 1. تطبيق تحديثات قاعدة البيانات

قم بتنفيذ الملف SQL التالي في Supabase SQL Editor:

```
database/update_certificates_system.sql
```

هذا الملف يقوم بـ:
- إضافة أعمدة جديدة لجدول `certificates`
- إضافة أعمدة لجدول `courses` لحفظ إعدادات الشهادات
- إنشاء دالة `check_student_eligibility()` للتحقق من أهلية الطالب
- إنشاء دالة `get_eligible_students()` لجلب الطلاب المؤهلين
- إنشاء Trigger للإصدار التلقائي للشهادات

### 2. التحقق من التحديثات

بعد تطبيق SQL، تحقق من:

```sql
-- التحقق من الأعمدة الجديدة في certificates
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'certificates';

-- التحقق من الأعمدة الجديدة في courses
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'courses' 
AND column_name LIKE 'certificate%';

-- التحقق من الدوال
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_name IN ('check_student_eligibility', 'get_eligible_students');

-- التحقق من Trigger
SELECT trigger_name 
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_auto_issue_certificate';
```

### 3. اختبار النظام

#### اختبار جلب الطلاب المؤهلين:
```sql
SELECT * FROM get_eligible_students('course_id_here');
```

#### اختبار التحقق من الأهلية:
```sql
SELECT check_student_eligibility('student_id_here', 'course_id_here');
```

## الميزات الجديدة

### 1. الإصدار التلقائي
- يتم إصدار الشهادات تلقائياً عند إكمال الطالب للكورس 100%
- يتطلب النجاح في الامتحان إذا كان موجوداً
- يمكن تفعيل/تعطيل الإصدار التلقائي لكل كورس

### 2. التخصيص
- إضافة شعار مقدم الخدمة
- إضافة توقيع مقدم الخدمة
- اختيار لون مخصص للشهادة

### 3. معايير الأهلية
الطالب مؤهل للحصول على الشهادة إذا:
- أكمل الكورس 100%
- نجح في الامتحان (إذا كان موجوداً)
- لا يملك شهادة سابقة لنفس الكورس

## الملفات المحدثة

### Backend (Database & Services)
- `database/update_certificates_system.sql` ✅
- `lib/data/models/certificate/certificate.dart` ✅
- `lib/data/services/certificate_service_v2.dart` ✅
- `lib/data/repositories/main_repository.dart` ✅

### Frontend (Bloc & UI)
- `lib/presentation/blocs/certificate_v2/certificate_v2_bloc.dart` ✅
- `lib/presentation/blocs/certificate_v2/certificate_v2_event.dart` ✅
- `lib/presentation/blocs/certificate_v2/certificate_v2_state.dart` ✅
- `lib/presentation/screens/certificate/dialogs/issue_certificates_dialog_v2.dart` ✅
- `lib/presentation/screens/certificate/dialogs/certificate_settings_dialog.dart` ✅

### القادم
- تحديث `course_certificates_screen.dart` لاستخدام النظام الجديد
- إنشاء قالب الشهادة الموحد
- إنشاء شاشة معاينة الشهادة

## ملاحظات مهمة

1. النظام الجديد (V2) يعمل بشكل مستقل عن النظام القديم
2. يمكن الانتقال التدريجي من النظام القديم إلى الجديد
3. جميع الدوال الجديدة تبدأ بـ V2 في Repository
4. الإصدار التلقائي يعمل فقط عند تحديث progress إلى 100%
