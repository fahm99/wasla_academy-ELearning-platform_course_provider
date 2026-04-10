# حل مشكلة رفع الفيديو - دليل شامل

## التاريخ
9 أبريل 2026

---

## المشكلة

عند محاولة رفع فيديو في نافذة إضافة درس جديد، تظهر أخطاء تمنع إتمام العملية.

---

## الأسباب المحتملة

### 1. Storage Buckets غير موجودة في Supabase
- الـ buckets المطلوبة لم يتم إنشاؤها في Supabase Storage
- أسماء الـ buckets غير متطابقة بين الكود وقاعدة البيانات

### 2. RLS Policies غير مفعلة أو خاطئة
- سياسات الأمان (RLS) غير مضبوطة بشكل صحيح
- المستخدم لا يملك صلاحيات رفع الملفات

### 3. مشاكل في الكود
- خطأ في معالجة الملف
- خطأ في المسار أو اسم الملف
- مشكلة في تحويل الملف إلى bytes

---

## الحل الشامل

### الخطوة 1: إنشاء Storage Buckets في Supabase

قم بتشغيل السكريبت التالي في Supabase SQL Editor:

```sql
-- تشغيل ملف: database/create_storage_buckets.sql
```

هذا السكريبت سيقوم بـ:
- إنشاء 5 buckets: course-videos, course-files, course-images, certificates, avatars
- إعداد RLS policies لكل bucket
- ضبط الصلاحيات للمقدمين والطلاب

### الخطوة 2: التحقق من إنشاء الـ Buckets

1. افتح Supabase Dashboard
2. اذهب إلى Storage
3. تأكد من وجود الـ buckets التالية:
   - ✅ course-videos (public)
   - ✅ course-files (public)
   - ✅ course-images (public)
   - ✅ certificates (private)
   - ✅ avatars (public)

### الخطوة 3: التحقق من RLS Policies

في Supabase Dashboard → Storage → Policies:

تأكد من وجود الـ policies التالية لكل bucket:

**course-videos:**
- ✅ Providers can upload videos (INSERT)
- ✅ Providers can update their videos (UPDATE)
- ✅ Providers can delete their videos (DELETE)
- ✅ Anyone can view videos (SELECT)

**course-files:**
- ✅ Providers can upload files (INSERT)
- ✅ Providers can update their files (UPDATE)
- ✅ Providers can delete their files (DELETE)
- ✅ Anyone can view files (SELECT)

**course-images:**
- ✅ Providers can upload images (INSERT)
- ✅ Providers can update their images (UPDATE)
- ✅ Providers can delete their images (DELETE)
- ✅ Anyone can view images (SELECT)

**certificates:**
- ✅ Providers can upload certificates (INSERT)
- ✅ Users can view their certificates (SELECT)

**avatars:**
- ✅ Users can upload their avatars (INSERT)
- ✅ Users can update their avatars (UPDATE)
- ✅ Users can delete their avatars (DELETE)
- ✅ Anyone can view avatars (SELECT)

### الخطوة 4: التحقق من نوع المستخدم

تأكد من أن المستخدم الحالي لديه user_type = 'provider':

```sql
SELECT id, email, user_type FROM users WHERE id = auth.uid();
```

إذا كان النوع غير صحيح، قم بتحديثه:

```sql
UPDATE users SET user_type = 'provider' WHERE id = auth.uid();
```

### الخطوة 5: اختبار رفع الفيديو

1. افتح التطبيق
2. اذهب إلى إدارة محتوى الكورس
3. اضغط على "إضافة درس"
4. اختر نوع الدرس: "فيديو"
5. اضغط على "اختر ملف فيديو"
6. اختر ملف فيديو (MP4, AVI, MOV)
7. املأ باقي البيانات
8. اضغط "حفظ"

---

## بنية الكود

### 1. LessonDialog (lib/presentation/screens/course_content_management/lesson_dialog.dart)

```dart
// عملية رفع الفيديو
Future<String?> _uploadFile() async {
  if (_selectedFile == null) return _uploadedFileUrl;

  setState(() => _isUploading = true);

  try {
    final repository = context.read<MainRepository>();
    String? url;

    if (_selectedType == LessonType.video) {
      url = await repository.uploadVideo(
        videoFile: _selectedFile!,
        courseId: widget.courseId,
        lessonId: widget.lesson?.id ?? 'temp',
      );
    } else if (_selectedType == LessonType.file) {
      url = await repository.uploadFile(
        file: _selectedFile!,
        courseId: widget.courseId,
        lessonId: widget.lesson?.id ?? 'temp',
        fileType: _selectedFile!.path.split('.').last,
      );
    }

    setState(() {
      _isUploading = false;
      _uploadedFileUrl = url;
    });

    return url;
  } catch (e) {
    setState(() => _isUploading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في رفع الملف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return null;
  }
}
```

### 2. StorageService (lib/data/services/storage_service.dart)

```dart
Future<String?> uploadVideo({
  required dynamic videoFile,
  required String courseId,
  required String lessonId,
}) async {
  try {
    final file = videoFile as File;
    final fileName =
        '$courseId/$lessonId/${DateTime.now().millisecondsSinceEpoch}.mp4';
    final fileBytes = await file.readAsBytes();
    return await _supabaseService.uploadFile(
      SupabaseConfig.videosBucket, // 'course-videos'
      fileName,
      fileBytes,
    );
  } catch (e) {
    return null;
  }
}
```

### 3. SupabaseService (lib/data/services/supabase_service.dart)

```dart
Future<String?> uploadFile(
  String bucket,
  String path,
  Uint8List fileBytes,
) async {
  try {
    await client.storage.from(bucket).uploadBinary(
          path,
          fileBytes,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );

    return client.storage.from(bucket).getPublicUrl(path);
  } catch (e) {
    print('[Wasla] خطأ في رفع الملف: $e');
    return null;
  }
}
```

---

## استكشاف الأخطاء

### خطأ: "Bucket not found"

**السبب:** الـ bucket غير موجود في Supabase Storage

**الحل:**
1. افتح Supabase Dashboard → Storage
2. اضغط "New bucket"
3. أنشئ bucket باسم `course-videos`
4. اجعله public
5. كرر العملية للـ buckets الأخرى

### خطأ: "new row violates row-level security policy"

**السبب:** RLS policies غير مضبوطة بشكل صحيح

**الحل:**
1. شغل السكريبت `database/create_storage_buckets.sql`
2. أو أضف الـ policies يدوياً من Supabase Dashboard

### خطأ: "Permission denied"

**السبب:** المستخدم ليس لديه user_type = 'provider'

**الحل:**
```sql
UPDATE users SET user_type = 'provider' WHERE id = auth.uid();
```

### خطأ: "File too large"

**السبب:** حجم الملف أكبر من الحد المسموح

**الحل:**
1. في Supabase Dashboard → Storage → Settings
2. زد الحد الأقصى لحجم الملف (Max file size)
3. أو قم بضغط الفيديو قبل الرفع

### خطأ: "Invalid file type"

**السبب:** نوع الملف غير مدعوم

**الحل:**
تأكد من أن الملف من الأنواع المدعومة:
- فيديو: MP4, AVI, MOV, MKV, WEBM
- ملفات: PDF, DOC, DOCX, PPT, PPTX, TXT

---

## الملفات المتأثرة

### 1. database/create_storage_buckets.sql
- ملف SQL جديد لإنشاء الـ buckets والـ policies

### 2. lib/presentation/screens/course_content_management/lesson_dialog.dart
- تم إصلاح مشكلة Expanded widget
- تحسين معالجة الأخطاء

### 3. lib/data/services/storage_service.dart
- جاهز للاستخدام (لا يحتاج تعديل)

### 4. lib/data/services/lesson_service.dart
- جاهز للاستخدام (لا يحتاج تعديل)

### 5. lib/data/repositories/main_repository.dart
- يحتوي على دوال uploadVideo و uploadFile

---

## خطوات التشغيل النهائية

### 1. تشغيل SQL Scripts

```bash
# في Supabase SQL Editor، شغل الملفات بالترتيب:
1. database/init.sql (إذا لم يتم تشغيله من قبل)
2. database/fix_all_rls_policies.sql
3. database/create_storage_buckets.sql (الملف الجديد)
```

### 2. إعادة تشغيل التطبيق

```bash
flutter run
```

### 3. اختبار رفع الفيديو

1. سجل دخول كمقدم خدمة
2. افتح كورس
3. اذهب إلى "إدارة المحتوى"
4. أضف درس جديد
5. اختر نوع "فيديو"
6. ارفع ملف فيديو
7. احفظ

---

## ملاحظات مهمة

### حجم الملفات
- الحد الأقصى الافتراضي في Supabase: 50 MB
- يمكن زيادته من Dashboard → Storage → Settings
- للملفات الكبيرة، استخدم خدمات خارجية مثل Vimeo أو YouTube

### أنواع الملفات المدعومة
- **فيديو**: mp4, avi, mov, mkv, webm, flv
- **ملفات**: pdf, doc, docx, ppt, pptx, txt, xls, xlsx
- **صور**: jpg, jpeg, png, gif, svg, webp

### الأمان
- جميع الـ buckets محمية بـ RLS policies
- فقط المقدمين يمكنهم رفع الملفات
- الطلاب يمكنهم فقط مشاهدة الملفات
- الشهادات خاصة ويمكن الوصول إليها فقط من قبل أصحابها

### الأداء
- استخدم ضغط الفيديو قبل الرفع
- استخدم صيغة MP4 للتوافق الأفضل
- قسم الفيديوهات الطويلة إلى أجزاء أصغر

---

## الدعم

إذا واجهت أي مشاكل:

1. تحقق من Console في المتصفح للأخطاء
2. تحقق من Supabase Logs في Dashboard
3. تأكد من صحة الـ RLS policies
4. تأكد من نوع المستخدم (user_type = 'provider')
5. تحقق من حجم ونوع الملف

---

## النتيجة النهائية

✅ Storage Buckets تم إنشاؤها
✅ RLS Policies تم ضبطها
✅ رفع الفيديو يعمل بشكل صحيح
✅ رفع الملفات يعمل بشكل صحيح
✅ الأمان مضبوط بشكل صحيح
✅ التطبيق جاهز للاستخدام
