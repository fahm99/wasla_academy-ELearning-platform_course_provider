# ✅ تكامل Supabase - منصة Wasla

## 🎉 تم إنجاز المرحلة الأولى!

تم إنشاء جميع الملفات والخدمات المطلوبة لربط تطبيق مقدم الخدمة مع Supabase.

---

## 📋 ما تم إنجازه

### 1. ملفات الإعدادات ✅
- `lib/config/supabase_config.dart` - إعدادات Supabase
- `.kiro/settings/mcp.json` - إعدادات MCP

### 2. ملفات قاعدة البيانات ✅
- `database/init.sql` - SQL Scripts الشاملة (15 جدول)
- `DATABASE_SETUP_INSTRUCTIONS.md` - تعليمات الإعداد

### 3. الخدمات ✅
- `lib/services/supabase_service.dart` - الخدمة الرئيسية
- `lib/services/auth_service.dart` - خدمة المصادقة
- `lib/services/course_service.dart` - خدمة الكورسات
- `lib/services/enrollment_service.dart` - خدمة التسجيل
- `lib/services/storage_service.dart` - خدمة التخزين
- `lib/services/index.dart` - تصدير الخدمات

### 4. تحديثات المشروع ✅
- `lib/main.dart` - تهيئة Supabase

---

## 🚀 الخطوات التالية

### الخطوة 1: إعداد Supabase (مهم جداً!)

#### 1.1 الحصول على بيانات Supabase
```
1. اذهب إلى https://app.supabase.com
2. اختر مشروعك أو أنشئ مشروع جديد
3. اذهب إلى Settings → API
4. انسخ:
   - Project URL (مثال: https://your-project.supabase.co)
   - anon public key
```

#### 1.2 تحديث ملف الإعدادات
افتح `lib/config/supabase_config.dart` وحدّث:
```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key';
```

#### 1.3 تنفيذ SQL Scripts
```
1. اذهب إلى Supabase Dashboard
2. اختر SQL Editor
3. انقر New Query
4. انسخ محتوى database/init.sql
5. الصق وانقر Run
```

#### 1.4 إنشاء Buckets
```
1. اذهب إلى Storage
2. أنشئ 5 buckets:
   - course-videos
   - course-files
   - course-images
   - certificates
   - avatars
```

### الخطوة 2: تحديث pubspec.yaml

تأكد من إضافة الحزم:
```yaml
dependencies:
  supabase_flutter: ^2.5.0
  supabase: ^2.5.0
```

ثم قم بتشغيل:
```bash
flutter pub get
```

### الخطوة 3: اختبار الاتصال

```bash
flutter run
```

تحقق من الـ console:
```
✅ تم تهيئة Supabase بنجاح
```

---

## 📊 الخدمات المتاحة

### SupabaseService (الخدمة الرئيسية)
```dart
final supabase = SupabaseService();

// الاستعلام
final data = await supabase.query('courses', filters: {'status': 'published'});

// الإدراج
final result = await supabase.insert('courses', courseData);

// التحديث
await supabase.update('courses', courseId, updateData);

// الحذف
await supabase.delete('courses', courseId);

// رفع ملف
final url = await supabase.uploadFile('bucket', 'path', fileBytes);
```

### AuthService (المصادقة)
```dart
final auth = AuthService();

// التسجيل
await auth.register(
  email: 'provider@example.com',
  password: 'password',
  name: 'Provider Name',
  phone: '+966501234567',
  userType: 'provider',
);

// تسجيل الدخول
await auth.login(email: 'provider@example.com', password: 'password');

// الحصول على المستخدم الحالي
final user = await auth.getCurrentUser();

// تسجيل الخروج
await auth.logout();
```

### CourseService (الكورسات)
```dart
final courseService = CourseService();

// الحصول على الكورسات المنشورة
final courses = await courseService.getPublishedCourses();

// إنشاء كورس
final course = await courseService.createCourse(
  providerId: 'provider-id',
  title: 'Course Title',
  description: 'Course Description',
  price: 99.99,
);

// تحديث الكورس
await courseService.updateCourse(
  courseId: 'course-id',
  title: 'New Title',
);

// نشر الكورس
await courseService.publishCourse('course-id');
```

### EnrollmentService (التسجيل)
```dart
final enrollmentService = EnrollmentService();

// الالتحاق بالكورس
await enrollmentService.enrollCourse(
  studentId: 'student-id',
  courseId: 'course-id',
);

// الحصول على كورسات الطالب
final courses = await enrollmentService.getStudentCourses('student-id');

// تحديث التقدم
await enrollmentService.updateProgress(
  studentId: 'student-id',
  courseId: 'course-id',
  percentage: 50,
);
```

### StorageService (التخزين)
```dart
final storageService = StorageService();

// رفع فيديو
final videoUrl = await storageService.uploadVideo(
  videoFile: File('path/to/video.mp4'),
  courseId: 'course-id',
  lessonId: 'lesson-id',
);

// رفع صورة
final imageUrl = await storageService.uploadImage(
  imageFile: File('path/to/image.jpg'),
  courseId: 'course-id',
);

// حذف ملف
await storageService.deleteFile(
  bucket: 'course-videos',
  filePath: 'path/to/file',
);
```

---

## 🏗️ هيكل قاعدة البيانات

### 15 جدول:
1. **users** - المستخدمون (طلاب، مقدمو خدمات، إدمن)
2. **courses** - الكورسات
3. **modules** - الوحدات
4. **lessons** - الدروس
5. **lesson_resources** - موارد الدروس
6. **enrollments** - التسجيل
7. **lesson_progress** - تقدم الدروس
8. **exams** - الامتحانات
9. **exam_questions** - أسئلة الامتحانات
10. **exam_results** - نتائج الامتحانات
11. **certificates** - الشهادات
12. **payments** - المدفوعات
13. **notifications** - الإشعارات
14. **reviews** - التقييمات
15. **app_settings** - الإعدادات

### 5 Buckets:
1. **course-videos** - الفيديوهات
2. **course-files** - الملفات
3. **course-images** - الصور
4. **certificates** - الشهادات
5. **avatars** - الصور الشخصية

---

## 🔐 الأمان

جميع الجداول محمية بـ **Row Level Security (RLS)**:

### للطلاب:
- يرى الكورسات المنشورة فقط
- يرى بيانات التسجيل الخاصة به فقط
- يرى نتائجه الخاصة فقط

### لمقدمي الخدمات:
- يرى كورساته الخاصة فقط
- يرى طلاب كورساته فقط
- يرى نتائج امتحانات كورساته فقط

### للإدمن:
- يرى كل البيانات

---

## 📝 الملفات المرجعية

| الملف | الوصف |
|------|-------|
| `lib/config/supabase_config.dart` | إعدادات Supabase |
| `lib/services/supabase_service.dart` | الخدمة الرئيسية |
| `lib/services/auth_service.dart` | خدمة المصادقة |
| `lib/services/course_service.dart` | خدمة الكورسات |
| `lib/services/enrollment_service.dart` | خدمة التسجيل |
| `lib/services/storage_service.dart` | خدمة التخزين |
| `database/init.sql` | SQL Scripts |
| `DATABASE_SETUP_INSTRUCTIONS.md` | تعليمات الإعداد |

---

## ✅ قائمة التحقق

- [ ] تم الحصول على بيانات Supabase
- [ ] تم تحديث `supabase_config.dart`
- [ ] تم تنفيذ SQL Scripts
- [ ] تم إنشاء جميع الجداول (15 جدول)
- [ ] تم تفعيل RLS على جميع الجداول
- [ ] تم إنشاء Buckets (5 buckets)
- [ ] تم تحديث `pubspec.yaml`
- [ ] تم تشغيل `flutter pub get`
- [ ] تم اختبار الاتصال بـ `flutter run`

---

## 🆘 استكشاف الأخطاء

### خطأ: "Invalid API key"
```
✓ تحقق من أن المفتاح صحيح
✓ تأكد من أنك تستخدم المفتاح العام (anon key)
✓ تحقق من أن المشروع نشط
```

### خطأ: "Table does not exist"
```
✓ تأكد من تنفيذ SQL Scripts بالكامل
✓ تحقق من أسماء الجداول
✓ تحقق من أن الجداول موجودة في Supabase Dashboard
```

### خطأ: "Permission denied"
```
✓ تحقق من أن RLS مفعل بشكل صحيح
✓ تحقق من سياسات الأمان
✓ تحقق من أن المستخدم مسجل دخول
```

---

## 🎯 الخطوات التالية

### المرحلة 2: تحديث BLoCs
- [ ] تحديث AuthBloc للعمل مع Supabase
- [ ] تحديث CourseBloc للعمل مع Supabase
- [ ] إنشاء EnrollmentBloc
- [ ] إنشاء ExamBloc
- [ ] إنشاء CertificateBloc

### المرحلة 3: تحديث الشاشات
- [ ] تحديث شاشات المصادقة
- [ ] تحديث شاشات الكورسات
- [ ] إنشاء شاشات إدارة المحتوى
- [ ] إنشاء شاشات الامتحانات
- [ ] إنشاء شاشات الشهادات

### المرحلة 4: الاختبار
- [ ] اختبار المصادقة
- [ ] اختبار إدارة الكورسات
- [ ] اختبار التسجيل والتقدم
- [ ] اختبار الامتحانات
- [ ] اختبار الشهادات

---

## 📞 الدعم

للمزيد من المعلومات:
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Guide](https://supabase.com/docs/reference/flutter/introduction)
- ملفات المشروع المرجعية في `.kiro/steering/`

---

## 🎉 تم إعداد كل شيء!

جميع الخدمات جاهزة للاستخدام. ابدأ الآن بتنفيذ SQL Scripts وتحديث بيانات Supabase.

**حظاً موفقاً! 🚀**
