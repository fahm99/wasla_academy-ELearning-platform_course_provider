---
inclusion: manual
---

# 🚀 خريطة الطريق والتنفيذ - منصة Wasla

## 📊 ملخص سريع

| الدور | الوظائف الأساسية | عدد User Stories |
|------|-----------------|-----------------|
| 🎓 الطالب | التعلم + الشراء + الشهادات | 22 |
| 🧑‍🏫 مقدم الخدمة | الإنشاء + الإدارة + الإصدار | 28 |
| 🛡️ الإدمن | المراقبة + الإدارة + التحكم | 27 |
| **المجموع** | | **77 User Story** |

---

## 🏗️ هيكل قاعدة البيانات (15 جدول)

```
1. users (المستخدمون)
2. courses (الكورسات)
3. modules (الوحدات)
4. lessons (الدروس)
5. lesson_resources (موارد الدروس)
6. enrollments (التسجيل)
7. lesson_progress (تقدم الدروس)
8. exams (الامتحانات)
9. exam_questions (أسئلة الامتحانات)
10. exam_results (نتائج الامتحانات)
11. certificates (الشهادات)
12. payments (المدفوعات)
13. notifications (الإشعارات)
14. reviews (التقييمات)
15. app_settings (الإعدادات)
```

---

## 🔐 سياسات الأمان (RLS)

### للطلاب:
```sql
-- يرى فقط الكورسات المنشورة
SELECT * FROM courses WHERE status = 'published'

-- يرى فقط بيانات التسجيل الخاصة به
SELECT * FROM enrollments WHERE student_id = auth.uid()

-- يرى فقط نتائجه الخاصة
SELECT * FROM exam_results WHERE student_id = auth.uid()
```

### لمقدمي الخدمات:
```sql
-- يرى فقط كورساته الخاصة
SELECT * FROM courses WHERE provider_id = auth.uid()

-- يرى فقط طلاب كورساته
SELECT * FROM enrollments 
WHERE course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid())

-- يرى فقط نتائج امتحانات كورساته
SELECT * FROM exam_results 
WHERE exam_id IN (SELECT id FROM exams 
  WHERE course_id IN (SELECT id FROM courses WHERE provider_id = auth.uid()))
```

### للإدمن:
```sql
-- يرى كل شيء
SELECT * FROM any_table
```

---

## 📱 الخدمات المطلوبة

### 1. SupabaseService (الخدمة الرئيسية)
```dart
class SupabaseService {
  // التهيئة والاتصال
  Future<void> initialize()
  
  // المصادقة
  Future<AuthResponse> signUp(email, password)
  Future<AuthResponse> signIn(email, password)
  Future<void> signOut()
  Future<User?> getCurrentUser()
  
  // الاستعلامات العامة
  Future<List<T>> query<T>(table, filters)
  Future<T> insert<T>(table, data)
  Future<T> update<T>(table, id, data)
  Future<void> delete(table, id)
}
```

### 2. AuthService
```dart
class AuthService {
  Future<bool> register(name, email, password, phone, userType)
  Future<bool> login(email, password)
  Future<void> logout()
  Future<bool> resetPassword(email)
  Future<User?> getCurrentUser()
}
```

### 3. CourseService
```dart
class CourseService {
  // للطلاب
  Future<List<Course>> getPublishedCourses()
  Future<Course> getCourseDetails(courseId)
  Future<List<Course>> searchCourses(query)
  
  // لمقدمي الخدمات
  Future<Course> createCourse(courseData)
  Future<void> updateCourse(courseId, courseData)
  Future<void> deleteCourse(courseId)
  Future<void> publishCourse(courseId)
  
  // للإدمن
  Future<List<Course>> getPendingCourses()
  Future<void> approveCourse(courseId)
  Future<void> rejectCourse(courseId, reason)
}
```

### 4. EnrollmentService
```dart
class EnrollmentService {
  Future<void> enrollCourse(studentId, courseId)
  Future<List<Course>> getStudentCourses(studentId)
  Future<double> getProgress(studentId, courseId)
  Future<void> updateProgress(studentId, courseId, percentage)
}
```

### 5. ExamService
```dart
class ExamService {
  // لمقدمي الخدمات
  Future<Exam> createExam(examData)
  Future<void> addQuestion(examId, questionData)
  Future<void> updateExam(examId, examData)
  
  // للطلاب
  Future<Exam> getExam(examId)
  Future<void> submitExam(examId, answers)
  Future<ExamResult> getResult(resultId)
  
  // للإدمن
  Future<List<ExamResult>> getExamResults(examId)
}
```

### 6. CertificateService
```dart
class CertificateService {
  // لمقدمي الخدمات
  Future<void> customizeTemplate(courseId, templateData)
  Future<void> issueCertificate(studentId, courseId)
  Future<void> issueBulkCertificates(studentIds, courseId)
  Future<void> enableAutoIssue(courseId)
  
  // للطلاب
  Future<List<Certificate>> getCertificates(studentId)
  Future<String> downloadCertificate(certificateId)
  
  // للإدمن
  Future<void> verifyCertificate(certificateId)
  Future<void> revokeCertificate(certificateId, reason)
}
```

### 7. PaymentService
```dart
class PaymentService {
  Future<PaymentIntent> createPaymentIntent(amount, courseId)
  Future<Payment> processPayment(paymentData)
  Future<List<Payment>> getPayments(userId)
  Future<void> refundPayment(paymentId)
}
```

### 8. StorageService
```dart
class StorageService {
  Future<String> uploadVideo(file, courseId)
  Future<String> uploadFile(file, lessonId)
  Future<String> uploadImage(file, type)
  Future<void> deleteFile(path)
}
```

### 9. NotificationService
```dart
class NotificationService {
  Future<void> sendNotification(userId, title, message, type)
  Future<void> sendBulkNotification(userIds, title, message)
  Future<List<Notification>> getNotifications(userId)
  Future<void> markAsRead(notificationId)
}
```

---

## 🏛️ هيكل المشروع النهائي

```
lib/
├── models/
│   ├── user.dart
│   ├── course.dart
│   ├── module.dart
│   ├── lesson.dart
│   ├── enrollment.dart
│   ├── exam.dart
│   ├── exam_question.dart
│   ├── exam_result.dart
│   ├── certificate.dart
│   ├── payment.dart
│   ├── notification.dart
│   ├── review.dart
│   ├── lesson_resource.dart
│   ├── lesson_progress.dart
│   └── index.dart
│
├── services/
│   ├── supabase_service.dart (الخدمة الرئيسية)
│   ├── auth_service.dart
│   ├── course_service.dart
│   ├── enrollment_service.dart
│   ├── exam_service.dart
│   ├── certificate_service.dart
│   ├── payment_service.dart
│   ├── storage_service.dart
│   ├── notification_service.dart
│   └── index.dart
│
├── repository/
│   ├── supabase_repository.dart
│   ├── main_repository.dart
│   └── index.dart
│
├── bloc/
│   ├── auth/
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   ├── course/
│   │   ├── course_bloc.dart
│   │   ├── course_event.dart
│   │   └── course_state.dart
│   ├── enrollment/
│   │   ├── enrollment_bloc.dart
│   │   ├── enrollment_event.dart
│   │   └── enrollment_state.dart
│   ├── exam/
│   │   ├── exam_bloc.dart
│   │   ├── exam_event.dart
│   │   └── exam_state.dart
│   ├── certificate/
│   │   ├── certificate_bloc.dart
│   │   ├── certificate_event.dart
│   │   └── certificate_state.dart
│   ├── payment/
│   │   ├── payment_bloc.dart
│   │   ├── payment_event.dart
│   │   └── payment_state.dart
│   ├── notification/
│   │   ├── notification_bloc.dart
│   │   ├── notification_event.dart
│   │   └── notification_state.dart
│   ├── navigation/
│   │   ├── navigation_bloc.dart
│   │   ├── navigation_event.dart
│   │   └── navigation_state.dart
│   └── bloc.dart
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── student/
│   │   ├── home_screen.dart
│   │   ├── courses_screen.dart
│   │   ├── course_details_screen.dart
│   │   ├── learning_screen.dart
│   │   ├── exam_screen.dart
│   │   ├── certificates_screen.dart
│   │   └── profile_screen.dart
│   ├── provider/
│   │   ├── dashboard_screen.dart
│   │   ├── courses_management_screen.dart
│   │   ├── create_course_screen.dart
│   │   ├── content_management_screen.dart
│   │   ├── exam_management_screen.dart
│   │   ├── students_screen.dart
│   │   ├── certificates_management_screen.dart
│   │   └── profile_screen.dart
│   ├── admin/
│   │   ├── dashboard_screen.dart
│   │   ├── users_management_screen.dart
│   │   ├── providers_approval_screen.dart
│   │   ├── courses_review_screen.dart
│   │   ├── payments_monitoring_screen.dart
│   │   ├── certificates_verification_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── settings_screen.dart
│   │   └── analytics_screen.dart
│   └── common/
│       ├── splash_screen.dart
│       └── error_screen.dart
│
├── widgets/
│   ├── common/
│   │   ├── custom_app_bar.dart
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── loading_widget.dart
│   │   └── error_widget.dart
│   ├── student/
│   │   ├── course_card.dart
│   │   ├── lesson_card.dart
│   │   ├── progress_indicator.dart
│   │   └── certificate_preview.dart
│   ├── provider/
│   │   ├── course_form.dart
│   │   ├── lesson_form.dart
│   │   ├── exam_form.dart
│   │   ├── certificate_template_editor.dart
│   │   └── student_list.dart
│   └── admin/
│       ├── user_card.dart
│       ├── course_review_card.dart
│       ├── payment_card.dart
│       └── analytics_chart.dart
│
├── theme/
│   ├── app_theme.dart
│   ├── app_colors.dart
│   └── app_text_styles.dart
│
├── utils/
│   ├── constants.dart
│   ├── validators.dart
│   ├── extensions.dart
│   ├── app_icons.dart
│   └── navigation_helper.dart
│
├── config/
│   ├── app_config.dart
│   └── supabase_config.dart
│
├── data/
│   └── mock_data.dart
│
└── main.dart
```

---

## 🚀 خطوات التنفيذ

### المرحلة 1: الإعداد الأساسي (أسبوع 1)
- [ ] إضافة حزم Supabase
- [ ] إنشاء جداول قاعدة البيانات
- [ ] تكوين سياسات الأمان (RLS)
- [ ] إنشاء SupabaseService

### المرحلة 2: المصادقة (أسبوع 2)
- [ ] إنشاء AuthService
- [ ] تحديث AuthBloc
- [ ] إنشاء شاشات المصادقة
- [ ] اختبار المصادقة

### المرحلة 3: إدارة الكورسات (أسبوع 3-4)
- [ ] إنشاء CourseService
- [ ] تحديث CourseBloc
- [ ] إنشاء شاشات الكورسات
- [ ] إنشاء خدمة التخزين

### المرحلة 4: التسجيل والتعلم (أسبوع 5-6)
- [ ] إنشاء EnrollmentService
- [ ] إنشاء LessonService
- [ ] تحديث شاشات التعلم
- [ ] تتبع التقدم

### المرحلة 5: الامتحانات (أسبوع 7-8)
- [ ] إنشاء ExamService
- [ ] إنشاء ExamBloc
- [ ] إنشاء شاشات الامتحانات
- [ ] نظام التصحيح

### المرحلة 6: الشهادات (أسبوع 9)
- [ ] إنشاء CertificateService
- [ ] إنشاء CertificateBloc
- [ ] نظام القوالب
- [ ] توليد الشهادات

### المرحلة 7: المدفوعات (أسبوع 10)
- [ ] إنشاء PaymentService
- [ ] تكامل بوابة الدفع
- [ ] إنشاء PaymentBloc
- [ ] إدارة المدفوعات

### المرحلة 8: الإشعارات (أسبوع 11)
- [ ] إنشاء NotificationService
- [ ] إنشاء NotificationBloc
- [ ] نظام الإشعارات الفورية
- [ ] إشعارات البريد الإلكتروني

### المرحلة 9: لوحة التحكم (أسبوع 12-13)
- [ ] لوحة تحكم الطالب
- [ ] لوحة تحكم مقدم الخدمة
- [ ] لوحة تحكم الإدمن
- [ ] التحليلات والتقارير

### المرحلة 10: الاختبار والتحسين (أسبوع 14-15)
- [ ] اختبار شامل
- [ ] تحسين الأداء
- [ ] تحسين الأمان
- [ ] الإطلاق

---

## 📊 مؤشرات النجاح

### الأداء:
- ⏱️ وقت تحميل الصفحة < 2 ثانية
- 📱 دعم جميع الأجهزة
- 🔄 معدل استجابة API < 500ms

### الأمان:
- 🔐 تشفير جميع البيانات
- 🛡️ سياسات RLS محكمة
- ✅ اختبارات أمان شاملة

### الجودة:
- ✅ تغطية اختبارات > 80%
- 📝 توثيق شامل
- 🐛 معدل الأخطاء < 1%

---

## 📝 ملاحظات مهمة

1. **قاعدة البيانات الموحدة**: جميع التطبيقات (Student App و Provider App) تستخدم نفس قاعدة البيانات
2. **الأمان**: كل دور له صلاحيات محددة عبر RLS
3. **التوسع**: الهيكل قابل للتوسع لإضافة ميزات جديدة
4. **الأداء**: استخدام الفهارس والـ Caching لتحسين الأداء
5. **المراقبة**: نظام شامل لمراقبة الأداء والأخطاء
