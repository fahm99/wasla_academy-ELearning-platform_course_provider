# 🚀 الخطوات التالية - منصة Wasla

## 📊 ملخص ما تم إنجازه

تم إنشاء بنية شاملة لربط تطبيق مقدم الخدمة مع Supabase:

✅ **الخدمات الأساسية** (5 خدمات)
✅ **إعدادات Supabase** 
✅ **SQL Scripts الشاملة** (15 جدول)
✅ **تعليمات الإعداد**

---

## 🎯 الخطوات الفورية (اليوم)

### 1. إعداد Supabase (30 دقيقة)

```bash
# الخطوة 1: الحصول على بيانات Supabase
# اذهب إلى https://app.supabase.com
# انسخ Project URL و anon key

# الخطوة 2: تحديث الإعدادات
# افتح lib/config/supabase_config.dart
# استبدل القيم

# الخطوة 3: تنفيذ SQL Scripts
# اذهب إلى Supabase SQL Editor
# انسخ محتوى database/init.sql
# الصق وانقر Run

# الخطوة 4: إنشاء Buckets
# اذهب إلى Storage
# أنشئ 5 buckets (course-videos, course-files, etc)
```

### 2. تحديث pubspec.yaml (5 دقائق)

```bash
flutter pub get
```

### 3. اختبار الاتصال (5 دقائق)

```bash
flutter run
```

تحقق من الـ console:
```
✅ تم تهيئة Supabase بنجاح
```

---

## 📋 الملفات المُنشأة

### الإعدادات:
- `lib/config/supabase_config.dart` - إعدادات Supabase
- `.kiro/settings/mcp.json` - إعدادات MCP

### الخدمات (5):
- `lib/services/supabase_service.dart` - الخدمة الرئيسية
- `lib/services/auth_service.dart` - المصادقة
- `lib/services/course_service.dart` - الكورسات
- `lib/services/enrollment_service.dart` - التسجيل
- `lib/services/storage_service.dart` - التخزين

### قاعدة البيانات:
- `database/init.sql` - SQL Scripts (15 جدول)
- `DATABASE_SETUP_INSTRUCTIONS.md` - تعليمات الإعداد

### التوثيق:
- `SUPABASE_INTEGRATION_COMPLETE.md` - ملخص التكامل
- `NEXT_STEPS.md` - هذا الملف

---

## 🔧 الخطوات التالية (الأسبوع القادم)

### المرحلة 1: تحديث BLoCs (3 أيام)

```dart
// تحديث AuthBloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();
  
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }
  
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final success = await _authService.login(
        email: event.email,
        password: event.password,
      );
      if (success) {
        final user = await _authService.getCurrentUser();
        emit(AuthSuccess(user: user));
      } else {
        emit(const AuthFailure(message: 'فشل تسجيل الدخول'));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
```

### المرحلة 2: تحديث الشاشات (5 أيام)

```dart
// تحديث شاشة الكورسات
class CoursesScreen extends StatefulWidget {
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final CourseService _courseService = CourseService();
  
  @override
  void initState() {
    super.initState();
    _loadCourses();
  }
  
  Future<void> _loadCourses() async {
    final courses = await _courseService.getPublishedCourses();
    // تحديث الواجهة
  }
}
```

### المرحلة 3: الاختبار (2 يوم)

```bash
# اختبار المصادقة
flutter test test/services/auth_service_test.dart

# اختبار الكورسات
flutter test test/services/course_service_test.dart

# اختبار التسجيل
flutter test test/services/enrollment_service_test.dart
```

---

## 📊 الخدمات المتاحة الآن

### 1. SupabaseService
```dart
final supabase = SupabaseService();

// الاستعلام
final courses = await supabase.query('courses');

// الإدراج
await supabase.insert('courses', courseData);

// التحديث
await supabase.update('courses', courseId, updateData);

// الحذف
await supabase.delete('courses', courseId);

// رفع ملف
final url = await supabase.uploadFile('bucket', 'path', bytes);
```

### 2. AuthService
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

// الحصول على المستخدم
final user = await auth.getCurrentUser();

// تسجيل الخروج
await auth.logout();
```

### 3. CourseService
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

// تحديث الكورس
await courseService.updateCourse(
  courseId: 'course-id',
  title: 'New Title',
);

// نشر الكورس
await courseService.publishCourse('course-id');
```

### 4. EnrollmentService
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

### 5. StorageService
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
```
users (المستخدمون)
├── courses (الكورسات)
│   ├── modules (الوحدات)
│   │   └── lessons (الدروس)
│   │       ├── lesson_resources (الموارد)
│   │       └── lesson_progress (التقدم)
│   ├── exams (الامتحانات)
│   │   ├── exam_questions (الأسئلة)
│   │   └── exam_results (النتائج)
│   ├── enrollments (التسجيل)
│   ├── certificates (الشهادات)
│   ├── payments (المدفوعات)
│   └── reviews (التقييمات)
├── notifications (الإشعارات)
└── app_settings (الإعدادات)
```

### 5 Buckets:
```
course-videos (الفيديوهات)
course-files (الملفات)
course-images (الصور)
certificates (الشهادات)
avatars (الصور الشخصية)
```

---

## ✅ قائمة التحقق

### اليوم:
- [ ] إعداد Supabase
- [ ] تنفيذ SQL Scripts
- [ ] إنشاء Buckets
- [ ] تحديث pubspec.yaml
- [ ] اختبار الاتصال

### الأسبوع القادم:
- [ ] تحديث BLoCs
- [ ] تحديث الشاشات
- [ ] الاختبار الشامل
- [ ] إصلاح الأخطاء

### الأسبوع التالي:
- [ ] إضافة خدمات إضافية (Exam, Certificate, Payment)
- [ ] إضافة BLoCs إضافية
- [ ] إضافة شاشات إضافية
- [ ] الاختبار النهائي

---

## 📞 الملفات المرجعية

| الملف | الوصف |
|------|-------|
| `SUPABASE_INTEGRATION_COMPLETE.md` | ملخص التكامل |
| `DATABASE_SETUP_INSTRUCTIONS.md` | تعليمات إعداد قاعدة البيانات |
| `database/init.sql` | SQL Scripts |
| `.kiro/steering/wasla-implementation-roadmap.md` | خريطة الطريق |
| `.kiro/steering/wasla-provider-stories.md` | متطلبات مقدم الخدمة |

---

## 🎯 الهدف النهائي

تطبيق متكامل لمقدم الخدمة يدعم:

✅ المصادقة والحسابات
✅ إدارة الكورسات (CRUD)
✅ إدارة المحتوى (الدروس والملفات)
✅ إدارة الامتحانات
✅ متابعة الطلاب
✅ إدارة الشهادات
✅ إدارة المدفوعات
✅ نظام الإشعارات

---

## 🚀 ابدأ الآن!

1. **اليوم**: إعداد Supabase (30 دقيقة)
2. **غداً**: تحديث BLoCs (1 يوم)
3. **بعد غد**: تحديث الشاشات (2 يوم)
4. **الأسبوع القادم**: الاختبار والإصلاح (2 يوم)

---

**حظاً موفقاً! 🎉**
