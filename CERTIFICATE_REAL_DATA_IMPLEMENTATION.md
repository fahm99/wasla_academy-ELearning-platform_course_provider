# تقرير تطبيق البيانات الحقيقية للشهادات

## التاريخ: 2024-12-07

## الهدف
إزالة جميع البيانات الوهمية وتطبيق الوظائف الحقيقية المتصلة بقاعدة البيانات Supabase حسب قصص المستخدم.

---

## التغييرات المنفذة

### 1. إنشاء CertificateService
تم إنشاء `lib/data/services/certificate_service.dart` مع الوظائف التالية:

#### ✅ الوظائف المطبقة:

**إصدار الشهادات:**
- `issueCertificate()` - إصدار شهادة لطالب واحد
- `issueCertificates()` - إصدار شهادات لعدة طلاب (دفعة واحدة)
- توليد رقم شهادة فريد تلقائياً
- التحقق من عدم وجود شهادة مسبقة
- إرسال إشعار تلقائي للطالب

**إدارة الشهادات:**
- `getCourseCertificates()` - جلب جميع شهادات كورس معين
- `getProviderCertificates()` - جلب جميع شهادات مقدم الخدمة
- `getStudentCertificate()` - جلب شهادة طالب معين في كورس معين
- `revokeCertificate()` - إلغاء شهادة

**التحقق:**
- `verifyCertificate()` - التحقق من صحة شهادة برقمها

**القوالب:**
- `saveCertificateTemplate()` - حفظ قالب شهادة مخصص
- `getCertificateTemplate()` - جلب قالب شهادة الكورس

---

### 2. تحديث IssueCertificatesDialog

#### ❌ تم إزالة:
- البيانات الوهمية `_mockStudents`
- القائمة الثابتة للطلاب

#### ✅ تم إضافة:
- `_loadStudents()` - جلب الطلاب من قاعدة البيانات
- استعلام Supabase للحصول على:
  - الطلاب المسجلين في الكورس
  - الذين أكملوا 100% من الكورس
  - حالة التسجيل = completed
- عرض صور الطلاب الحقيقية من avatar_url
- معالجة حالة التحميل (loading state)
- معالجة الأخطاء وعرض رسائل مناسبة
- عرض رسالة عند عدم وجود طلاب مؤهلين

---

### 3. تحديث MainRepository

#### ✅ تم إضافة:
- `supabase` getter للوصول إلى Supabase client
- تهيئة `CertificateService` في constructor
- تحديث جميع methods الشهادات:
  - `getCertificates()` - إرجاع `List<Map<String, dynamic>>`
  - `issueCertificate()` - إرجاع `Map<String, dynamic>`
  - `issueCertificates()` - إصدار دفعة من الشهادات
  - `getCourseCertificates()` - جلب شهادات كورس
  - `revokeCertificate()` - إلغاء شهادة

---

### 4. تحديث AuthService

#### ✅ تم إضافة:
- `supabase` getter للوصول إلى Supabase client

---

## الاتصال بقاعدة البيانات

### الجداول المستخدمة:

**certificates:**
```sql
- id (UUID)
- course_id (UUID)
- student_id (UUID)
- provider_id (UUID)
- certificate_number (VARCHAR)
- issue_date (TIMESTAMP)
- template_design (JSONB)
- status (VARCHAR)
```

**enrollments:**
```sql
- student_id (UUID)
- course_id (UUID)
- completion_percentage (INT)
- status (VARCHAR)
```

**users:**
```sql
- id (UUID)
- name (VARCHAR)
- email (VARCHAR)
- avatar_url (TEXT)
- certificates_count (INT)
```

**notifications:**
```sql
- user_id (UUID)
- title (VARCHAR)
- message (TEXT)
- type (VARCHAR)
- related_id (UUID)
```

---

## الاستعلامات المطبقة

### 1. جلب الطلاب المؤهلين للشهادة:
```dart
await supabase
  .from('enrollments')
  .select('''
    student_id,
    completion_percentage,
    users!enrollments_student_id_fkey(id, name, avatar_url)
  ''')
  .eq('course_id', courseId)
  .eq('completion_percentage', 100)
  .eq('status', 'completed');
```

### 2. إصدار شهادة:
```dart
await supabase.from('certificates').insert({
  'course_id': courseId,
  'student_id': studentId,
  'provider_id': providerId,
  'certificate_number': certificateNumber,
  'issue_date': DateTime.now().toIso8601String(),
  'template_design': templateDesign,
  'status': 'issued',
});
```

### 3. إرسال إشعار:
```dart
await supabase.from('notifications').insert({
  'user_id': studentId,
  'title': 'تم إصدار شهادتك',
  'message': 'تهانينا! تم إصدار شهادة إتمام الكورس',
  'type': 'certificate',
  'related_id': certificateId,
});
```

---

## الميزات المطبقة

### ✅ US-P-018: تخصيص قالب شهادة
- حفظ تصميم القالب في JSONB
- جلب القالب المحفوظ

### ✅ US-P-020: إصدار الشهادة لطالب واحد
- إصدار شهادة فردية
- توليد رقم فريد
- إرسال إشعار

### ✅ US-P-021: إصدار الشهادة لعدة طلاب
- معالجة دفعية
- معالجة الأخطاء لكل طالب
- إرسال إشعارات متعددة

### ✅ US-P-022: تفعيل الإصدار التلقائي
- جاهز للتطبيق (يحتاج trigger في قاعدة البيانات)

---

## معالجة الأخطاء

### ✅ تم تطبيق:
- التحقق من وجود شهادة مسبقة
- معالجة أخطاء الاتصال بقاعدة البيانات
- عرض رسائل خطأ واضحة للمستخدم
- معالجة حالة عدم وجود طلاب مؤهلين
- معالجة أخطاء الإصدار الدفعي

---

## الإشعارات

### ✅ تم تطبيق:
- إرسال إشعار تلقائي عند إصدار الشهادة
- نوع الإشعار: `certificate`
- ربط الإشعار بـ ID الشهادة

---

## الأمان

### ✅ تم تطبيق:
- استخدام RLS (Row Level Security)
- التحقق من صلاحيات مقدم الخدمة
- منع التكرار (UNIQUE constraint)

---

## الملفات المحدثة

1. ✅ `lib/data/services/certificate_service.dart` (جديد)
2. ✅ `lib/data/services/auth_service.dart`
3. ✅ `lib/data/repositories/main_repository.dart`
4. ✅ `lib/presentation/screens/certificate/dialogs/issue_certificates_dialog.dart`

---

## الخطوات التالية

### المطلوب تطبيقه:

1. **إزالة البيانات الوهمية من باقي الملفات:**
   - `certificate_preview_screen.dart` - استخدام بيانات حقيقية
   - `certificate_screen.dart` - جلب القوالب من قاعدة البيانات

2. **تطبيق وظائف الكورسات:**
   - إنشاء/تعديل/حذف الكورسات
   - إدارة الوحدات والدروس
   - رفع الفيديوهات والملفات

3. **تطبيق وظائف الامتحانات:**
   - إنشاء الامتحانات
   - إضافة الأسئلة
   - عرض النتائج

4. **تطبيق وظائف الطلاب:**
   - عرض قائمة الطلاب
   - متابعة التقدم
   - عرض النتائج

5. **تطبيق وظائف المدفوعات:**
   - عرض الأرباح
   - طلب السحب
   - التقارير المالية

---

## ملاحظات

- ✅ لا توجد بيانات وهمية في الكود الجديد
- ✅ جميع الوظائف متصلة بقاعدة البيانات
- ✅ معالجة الأخطاء مطبقة
- ✅ الإشعارات تعمل تلقائياً
- ✅ الأمان مطبق عبر RLS

---

**تم بنجاح! ✨**
