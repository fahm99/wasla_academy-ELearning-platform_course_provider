# Wasla Academy - AI Prompt for Student App Complete Rewrite

## 🎯 Objective
Rewrite the Flutter Student Application (Wasla Academy) from scratch with:
- Clean Architecture (BLoC pattern)
- Full Supabase database integration
- All missing features implemented
- Production-ready code
- NO MOCK DATA - Real database integration

---

## 📊 Project Analysis

### Current Flutter Project Location
```
/workspace/project/wasla_academy-ELearning-platform_course_provider/
```

### Features Currently Implemented
1. ✅ Authentication (Login/Register)
2. ✅ Course Listing & Details
3. ✅ Video Player
4. ✅ Basic Enrollments
5. ✅ Basic Progress Tracking

### Features NOT Implemented (Need to Add)
1. ❌ Complete Exam System (MCQ, True/False, Auto-grading, Results)
2. ❌ Certificate Generation & PDF Download & Sharing
3. ❌ Complete Payment Flow (Request, Receipt Upload, Verification)
4. ❌ Complete Notifications System
5. ❌ Full Progress Tracking (Module/Lesson completion)
6. ❌ Student Profile Management (Edit, Password Change)
7. ❌ Course Search & Filter
8. ❌ Course Reviews & Ratings
9. ❌ Downloadable Resources Management
10. ❌ Course Favorites/Wishlist
11. ❌ My Courses (Enrolled Courses List)
12. ❌ Exam Attempts Control

---

## 🗄️ DATABASE - CRITICAL

### Database SQL File
**Location:** `/workspace/project/wasla_academy-ELearning-platform_course_provider/database/wasla_full_database.sql`

This file contains COMPLETE database schema including:
- 17 tables (users, courses, modules, lessons, enrollments, lesson_progress, exams, exam_questions, exam_results, certificates, certificate_templates, payments, payment_settings, notifications, reviews, app_settings, lesson_resources)
- Row Level Security (RLS) policies
- Triggers for auto-updates
- Storage buckets configuration

### Key Database Details
- **Supabase URL:** `https://hmgisljihrsztskvmbfd.supabase.co`
- **Anon Key:** `sb_publishable_-ZiqWMN8A8uZdjO6S0prlQ_6GVN6my8`

### Primary Tables Structure:
```sql
-- USERS: id, email, password_hash, full_name, phone, role (student/provider/admin), avatar_url, bio, created_at
-- COURSES: id, provider_id, title, description, category, level, price, thumbnail_url, cover_image_url, status, students_count, rating
-- MODULES: id, course_id, title, description, order_index
-- LESSONS: id, module_id, course_id, title, type (video/text/file/link), content, video_url, file_url, duration, order_index
-- ENROLLMENTS: id, student_id, course_id, enrollment_date, completion_percentage, status (active/completed/dropped)
-- LESSON_PROGRESS: id, student_id, lesson_id, is_completed, watch_time, completed_at
-- EXAMS: id, course_id, title, description, duration, passing_score, max_attempts, auto_certificate, status
-- EXAM_QUESTIONS: id, exam_id, question, question_type (mcq/trueFalse), options[], correct_option, order_index
-- EXAM_RESULTS: id, exam_id, student_id, score, passed, attempt_number, answers, completed_at
-- CERTIFICATES: id, course_id, student_id, provider_id, certificate_number, issue_date, status
-- PAYMENTS: id, student_id, course_id, provider_id, amount, payment_method, receipt_image_url, status, verified_by
-- NOTIFICATIONS: id, user_id, title, message, type, is_read
```

---

## 🏗️ REQUIRED ARCHITECTURE

### Clean Architecture with BLoC

```
lib/
├── main.dart                     # App entry point
├── app.dart                     # MaterialApp configuration
│
├── core/                        # Core utilities
│   ├── config/
│   │   ├── app_config.dart      # App constants
│   │   └── supabase_config.dart # Supabase initialization
│   ├── theme/
│   │   ├── app_theme.dart       # ThemeData (Keep current colors!)
│   │   └── colors.dart          # Color constants
│   ├── utils/
│   │   ├── validators.dart      # Form validators
│   │   ├── formatters.dart      # Date/currency formatters
│   │   └── extensions.dart      # Extensions
│   └── constants/
│       ├── api_constants.dart
│       └── app_strings.dart
│
├── data/                        # Data Layer
│   ├── models/                  # Data Models (JSON serialization)
│   │   ├── user_model.dart
│   │   ├── course_model.dart
│   │   ├── module_model.dart
│   │   ├── lesson_model.dart
│   │   ├── enrollment_model.dart
│   │   ├── exam_model.dart
│   │   ├── exam_question_model.dart
│   │   ├── exam_result_model.dart
│   │   ├── certificate_model.dart
│   │   ├── payment_model.dart
│   │   └── notification_model.dart
│   ├── repositories/            # Data repositories
│   │   ├── auth_repository.dart
│   │   ├── course_repository.dart
│   │   ├── enrollment_repository.dart
│   │   ├── lesson_repository.dart
│   │   ├── exam_repository.dart
│   │   ├── certificate_repository.dart
│   │   └── payment_repository.dart
│   └── services/
│       ├── supabase_service.dart    # Supabase client
│       └── storage_service.dart    # File uploads
│
├── bloc/                        # BLoC State Management
│   ├── auth/
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   ├── courses/
│   │   ├── course_list_bloc.dart
│   │   ├── course_detail_bloc.dart
│   │   └── course_event.dart
│   ├── lessons/
│   │   ├── lesson_bloc.dart
│   │   ├── lesson_event.dart
│   │   └── lesson_state.dart
│   ├── exams/
│   │   ├── exam_bloc.dart
│   │   ├── exam_event.dart
│   │   └── exam_state.dart
│   ├── certificates/
│   │   ├── certificate_bloc.dart
│   │   └── certificate_event.dart
│   ├── payments/
│   │   ├── payment_bloc.dart
│   │   └── payment_event.dart
│   └── profile/
│       ├── profile_bloc.dart
│       └── profile_event.dart
│
├── presentation/               # UI Layer
│   ├── screens/
│   │   ├── splash/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── courses/
│   │   ├── lessons/
│   │   ├── exams/
│   │   ├── certificates/
│   │   ├── payments/
│   │   ├── profile/
│   │   └── settings/
│   └── widgets/
│       ├── common/
│       ├── course/
│       ├── lesson/
│       ├── exam/
│       └── certificate/
│
└── routes/
    ├── app_router.dart
    └── route_constants.dart
```

---

## 📱 STUDENT USER STORIES - COMPLETE

### 1. Authentication
- [ ] تسجيل الدخول (email + password)
- [ ] إنشاء حساب جديد كـ Student
- [ ] استعادة كلمة المرور
- [ ] تسجيل الخروج
- [ ] إدارة الجلسة (Token storage)

### 2. Course Discovery (Home Screen)
- [ ] عرض الكورسات المنشورة
- [ ] عرض الكورسات المميزة (Featured)
- [ ] عرض أحدث الكورسات
- [ ] البحث عن كورس (اسم، وصف، تصنيف)
- [ ] تصفية حسب: السعر، المستوى، التصنيف
- [ ] عرض تفاصيل الكورس الكامل

### 3. My Courses (Enrolled Courses)
- [ ] عرض قائمة الكورسات المسجل فيها
- [ ] عرض تقدم كل كورس
- [ ] متابعة آخر درس
- [ ] عرض الكورسات المكتملة

### 4. Course Detail
- [ ] عرض الوصف الكامل
- [ ] عرض المراجعات والتقييمات
- [ ] عرض المحاور (Modules + Lessons)
- [ ] عرض معلومات المدرب
- [ ] التسجيل في الكورس (مجاني/مدفوع)

### 5. Enrollment & Payment
- [ ] التسجيل في كورس مجاني (فوري)
- [ ] طلب التسجيل في كورس مدفوع
- [ ] عرض طرق الدفع المتاحة
- [ ] رفع إيصال الدفع (Image picker)
- [ ] عرض حالة الطلب (معلق/مكتمل/مرفوض)
- [ ] عرض تاريخ المدفوعات

### 6. Learning Experience
- [ ] عرض قائمة الوحدات
- [ ] عرض قائمة الدروس داخل الوحدة
- [ ] تشغيل فيديو (Chewie/Video Player)
- [ ] قراءة محتوى نصي
- [ ] تحميل ملفات PDF
- [ ] فتح روابط خارجية
- [ ] وضع العلامات (مكتمل/غير مكتمل)
- [ ] تحديث تقدم الدرس في DB
- [ ] عرض نسبة تقدم الكورس

### 7. Exams System
- [ ] عرض الامتحانات المتاحة للكورس
- [ ] عرض تفاصيل الامتحان (المدة، درجة النجاح، المحاولات)
- [ ] بدء الامتحان
- [ ] عرض الأسئلة (MCQ + True/False)
- [ ] تحديد الإجابات
- [ ] عرض المؤقت (Timer)
- [ ] تصحيح تلقائي
- [ ] عرض النتيجة النهائية
- [ ] عرض حالة النجاح/الرسوب
- [ ] التحقق من عدد المحاولات
- [ ] عرض محاولات سابقة

### 8. Certificates
- [ ] عرض قائمة الشهادات
- [ ] عرض تفاصيل الشهادة
- [ ] توليد PDF للشهادة
- [ ] تحميل الشهادة
- [ ] مشاركة الشهادة
- [ ] التحقق من صحة الشهادة

### 9. Profile & Settings
- [ ] عرض الملف الشخصي
- [ ] تعديل الاسم ورقم الهاتف
- [ ] رفع صورة شخصية
- [ ] تغيير كلمة المرور
- [ ] عرض الإحصائيات (الكورسات، الشهادات، الوقت)
- [ ] عرض الإشعارات
- [ ] قراءة/حذف إشعار

### 10. Favorites
- [ ] إضافة كورس للمفضلة
- [ ] عرض قائمة المفضلة
- [ ] إزالة من المفضلة

---

## 🎨 DESIGN REQUIREMENTS (STRICT)

### Keep Current Design
- **Primary Color:** #3B82F6 (Blue)
- **Secondary Color:** #10B981 (Green)  
- **Error Color:** #EF4444 (Red)
- **Background:** #F9FAFB
- **Surface:** #FFFFFF
- **Text Primary:** #111827
- **Text Secondary:** #6B7280
- **Font:** Cairo or Tajawal (Arabic)
- **Layout:** RTL (Right to Left)

### Bottom Navigation (5 tabs)
1. 🏠 الرئيسية (Home)
2. 📚 الكورسات (Courses)
3. 🎓 تعلماتي (My Learning)
4. 📜 الشهادات (Certificates)
5. 👤 الملف (Profile)

### Key Components
- CourseCard: Image + Title + Price + Rating
- LessonTile: Icon + Title + Duration + Status
- VideoPlayer: Full controls + Quality
- ExamCard: Title + Questions count + Duration
- CertificateCard: Course name + Date + Download
- PaymentCard: Amount + Status + Date

---

## 🚀 IMPLEMENTATION RULES

### CRITICAL - NO MOCK DATA
- Every data display must come from Supabase
- All forms write to Supabase
- All actions communicate with real API
- Loading states for every async operation
- Error handling for every database operation

### Database Integration
```dart
// Initialize Supabase
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = SupabaseClient(
  'https://hmgisljihrsztskvmbfd.supabase.co',
  'sb_publishable_-ZiqWMN8A8uZdjO6S0prlQ_6GVN6my8'
);

// Example queries:
// Fetch courses
final courses = await supabase.from('courses').select().eq('status', 'published');

// Fetch enrollments for student
final enrollments = await supabase.from('enrollments').select('*, course:courses(*)').eq('student_id', userId);

// Update lesson progress
await supabase.from('lesson_progress').upsert({
  'student_id': studentId,
  'lesson_id': lessonId,
  'is_completed': true,
  'completed_at': DateTime.now().toIso8601String()
});
```

### State Management (BLoC)
```dart
// Each feature has:
// - FeatureBloc (extends Bloc)
// - FeatureEvent (extends Equatable)
// - FeatureState (extends Equatable)

// Example:
class CourseListBloc extends Bloc<CourseListEvent, CourseListState> {
  final CourseRepository repository;
  
  Future<void> _onLoadCourses(LoadCourses event, Emitter<CourseListState> emit) async {
    emit(CourseListLoading());
    try {
      final courses = await repository.getPublishedCourses();
      emit(CourseListLoaded(courses));
    } catch (e) {
      emit(CourseListError(e.toString()));
    }
  }
}
```

### Error Handling
- Try-catch for all async operations
- User-friendly error messages in Arabic
- Retry buttons for failed operations
- Empty states for no data

---

## 📦 REQUIRED PACKAGES

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Database
  supabase_flutter: ^2.3.0
  
  # UI
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  google_fonts: ^6.1.0
  
  # Video
  video_player: ^2.8.2
  chewie: ^1.7.4
  
  # PDF & Printing
  pdf: ^3.10.7
  printing: ^5.12.0
  
  # File & Image
  path_provider: ^2.1.2
  image_picker: ^1.0.7
  file_picker: ^6.1.1
  
  # Utils
  shared_preferences: ^2.2.2
  url_launcher: ^6.2.4
  share_plus: ^7.2.1
  get_it: ^7.6.7
  intl: ^0.19.0
```

---

## 📋 OUTPUT REQUIREMENTS

1. **Complete Flutter project** in `student_app/` folder
2. **All user stories implemented** as listed
3. **Real Supabase integration** - no mock data
4. **BLoC pattern** for all features
5. **Clean Architecture** layers
6. **Production ready** with error handling
7. **Current design preserved** (colors, fonts, RTL)
8. **Builds successfully** (flutter build apk)

---

## 📁 File Structure to Create

```
student_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── config/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── constants/
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   ├── bloc/
│   │   ├── auth/
│   │   ├── courses/
│   │   ├── lessons/
│   │   ├── exams/
│   │   ├── certificates/
│   │   ├── payments/
│   │   └── profile/
│   ├── presentation/
│   │   ├── screens/
│   │   └── widgets/
│   └── routes/
├── pubspec.yaml
└── database/
    └── wasla_full_database.sql (copy from source)
```