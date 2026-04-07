# 🚀 ابدأ من هنا - منصة Wasla

## 👋 مرحباً بك!

تم إعداد كل شيء لربط تطبيق مقدم الخدمة مع Supabase. اتبع هذه الخطوات البسيطة للبدء.

---

## ⏱️ الوقت المتوقع: 1 ساعة

---

## 📋 الخطوات

### الخطوة 1: الحصول على بيانات Supabase (10 دقائق)

1. اذهب إلى [Supabase Dashboard](https://app.supabase.com)
2. اختر مشروعك أو أنشئ مشروع جديد
3. اذهب إلى **Settings** → **API**
4. انسخ:
   - **Project URL** (مثال: `https://your-project.supabase.co`)
   - **anon public** (المفتاح العام)

### الخطوة 2: تحديث الإعدادات (5 دقائق)

افتح `lib/config/supabase_config.dart`:

```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key';
```

استبدل القيم ببيانات مشروعك.

### الخطوة 3: تنفيذ SQL Scripts (15 دقيقة)

1. اذهب إلى Supabase Dashboard
2. اختر **SQL Editor** من القائمة الجانبية
3. انقر على **New Query**
4. افتح ملف `database/init.sql`
5. انسخ المحتوى بالكامل
6. الصق في محرر SQL
7. انقر **Run** (أو اضغط `Ctrl+Enter`)

✅ تحقق من أن جميع الجداول تم إنشاؤها بنجاح

### الخطوة 4: إنشاء Buckets (10 دقائق)

1. اذهب إلى **Storage** في Supabase Dashboard
2. انقر **Create a new bucket** لكل من:
   - `course-videos`
   - `course-files`
   - `course-images`
   - `certificates`
   - `avatars`

### الخطوة 5: تحديث pubspec.yaml (5 دقائق)

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

### الخطوة 6: اختبار الاتصال (5 دقائق)

```bash
flutter run
```

تحقق من الـ console:

```
✅ تم تهيئة Supabase بنجاح
```

---

## ✅ تم!

جميع الخدمات جاهزة للاستخدام الآن.

---

## 📚 الملفات المهمة

| الملف | الوصف |
|------|-------|
| `lib/config/supabase_config.dart` | إعدادات Supabase |
| `lib/services/supabase_service.dart` | الخدمة الرئيسية |
| `lib/services/auth_service.dart` | خدمة المصادقة |
| `lib/services/course_service.dart` | خدمة الكورسات |
| `lib/services/enrollment_service.dart` | خدمة التسجيل |
| `lib/services/storage_service.dart` | خدمة التخزين |
| `database/init.sql` | SQL Scripts |

---

## 🔧 الخدمات المتاحة

### 1. المصادقة

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
await auth.login(email: 'email', password: 'password');

// الحصول على المستخدم الحالي
final user = await auth.getCurrentUser();

// تسجيل الخروج
await auth.logout();
```

### 2. الكورسات

```dart
final courseService = CourseService();

// الحصول على الكورسات
final courses = await courseService.getPublishedCourses();

// إنشاء كورس
final course = await courseService.createCourse(
  providerId: 'provider-id',
  title: 'Course Title',
  description: 'Description',
  price: 99.99,
);

// نشر الكورس
await courseService.publishCourse('course-id');
```

### 3. التسجيل

```dart
final enrollmentService = EnrollmentService();

// الالتحاق بالكورس
await enrollmentService.enrollCourse(
  studentId: 'student-id',
  courseId: 'course-id',
);

// تحديث التقدم
await enrollmentService.updateProgress(
  studentId: 'student-id',
  courseId: 'course-id',
  percentage: 50,
);
```

### 4. التخزين

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
```

---

## 📖 المزيد من المعلومات

- `DATABASE_SETUP_INSTRUCTIONS.md` - تعليمات إعداد قاعدة البيانات
- `SUPABASE_INTEGRATION_COMPLETE.md` - ملخص التكامل
- `NEXT_STEPS.md` - الخطوات التالية
- `PROJECT_STATUS.md` - حالة المشروع

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

بعد إكمال الخطوات أعلاه:

1. **تحديث BLoCs** - تحديث الـ BLoCs للعمل مع Supabase
2. **تحديث الشاشات** - تحديث الواجهات للعمل مع الخدمات الجديدة
3. **الاختبار** - اختبار جميع الوظائف
4. **الإطلاق** - إطلاق التطبيق

---

## 📞 الدعم

للمزيد من المعلومات:
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Guide](https://supabase.com/docs/reference/flutter/introduction)

---

## 🎉 ابدأ الآن!

اتبع الخطوات أعلاه وستكون جاهزاً للبدء في دقائق!

**حظاً موفقاً! 🚀**
