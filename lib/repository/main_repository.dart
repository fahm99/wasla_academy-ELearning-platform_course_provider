import '../services/index.dart';
import '../models/index.dart';

/// Repository الرئيسي للتعامل مع Supabase
class MainRepository {
  final AuthService _authService = AuthService();
  final CourseService _courseService = CourseService();
  final ModuleService _moduleService = ModuleService();
  final LessonService _lessonService = LessonService();
  final ExamService _examService = ExamService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  final CertificateService _certificateService = CertificateService();
  final NotificationService _notificationService = NotificationService();
  final PaymentService _paymentService = PaymentService();
  final SettingsService _settingsService = SettingsService();
  final StorageService _storageService = StorageService();

  // ============================================
  // المصادقة
  // ============================================

  Future<bool> login(String email, String password) async {
    return await _authService.login(email: email, password: password);
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    return await _authService.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
      userType: 'provider',
    );
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<bool> isLoggedIn() async {
    return _authService.isLoggedIn();
  }

  Future<User?> getUser() async {
    return await _authService.getCurrentUser();
  }

  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? bio,
    String? avatarUrl,
  }) async {
    return await _authService.updateUserProfile(
      userId: userId,
      name: name,
      phone: phone,
      bio: bio,
      avatarUrl: avatarUrl,
    );
  }

  // ============================================
  // الكورسات
  // ============================================

  Future<List<Course>> getCourses() async {
    final user = await getUser();
    if (user == null) return [];
    return await _courseService.getProviderCourses(user.id);
  }

  Future<Course?> getCourseById(String courseId) async {
    return await _courseService.getCourseDetails(courseId);
  }

  Future<bool> addCourse(Course course) async {
    final created = await _courseService.createCourse(
      providerId: course.providerId,
      title: course.title,
      description: course.description,
      category: course.category,
      level: course.level?.name,
      price: course.price,
      durationHours: course.durationHours,
      thumbnailUrl: course.thumbnailUrl,
      coverImageUrl: course.coverImageUrl,
    );
    return created != null;
  }

  Future<bool> updateCourse(Course course) async {
    return await _courseService.updateCourse(
      courseId: course.id,
      title: course.title,
      description: course.description,
      category: course.category,
      level: course.level?.name,
      price: course.price,
      durationHours: course.durationHours,
      thumbnailUrl: course.thumbnailUrl,
      coverImageUrl: course.coverImageUrl,
      status: course.status.name,
    );
  }

  Future<bool> deleteCourse(String courseId) async {
    return await _courseService.deleteCourse(courseId);
  }

  Future<bool> publishCourse(String courseId) async {
    return await _courseService.publishCourse(courseId);
  }

  Future<bool> unpublishCourse(String courseId) async {
    return await _courseService.unpublishCourse(courseId);
  }

  Future<List<Course>> searchCourses(String query) async {
    return await _courseService.searchCourses(query);
  }

  // ============================================
  // الوحدات
  // ============================================

  Future<List<Module>> getCourseModules(String courseId) async {
    return await _moduleService.getCourseModules(courseId);
  }

  Future<Module?> getModule(String moduleId) async {
    return await _moduleService.getModule(moduleId);
  }

  Future<Module?> createModule({
    required String courseId,
    required String title,
    String? description,
    required int orderNumber,
  }) async {
    return await _moduleService.createModule(
      courseId: courseId,
      title: title,
      description: description,
      orderNumber: orderNumber,
    );
  }

  Future<bool> updateModule({
    required String moduleId,
    String? title,
    String? description,
    int? orderNumber,
  }) async {
    return await _moduleService.updateModule(
      moduleId: moduleId,
      title: title,
      description: description,
      orderNumber: orderNumber,
    );
  }

  Future<bool> deleteModule(String moduleId) async {
    return await _moduleService.deleteModule(moduleId);
  }

  // ============================================
  // الدروس
  // ============================================

  Future<List<Lesson>> getModuleLessons(String moduleId) async {
    return await _lessonService.getModuleLessons(moduleId);
  }

  Future<List<Lesson>> getCourseLessons(String courseId) async {
    return await _lessonService.getCourseLessons(courseId);
  }

  Future<Lesson?> getLesson(String lessonId) async {
    return await _lessonService.getLesson(lessonId);
  }

  Future<Lesson?> createLesson({
    required String moduleId,
    required String courseId,
    required String title,
    String? description,
    required int orderNumber,
    LessonType? lessonType,
    String? videoUrl,
    int? videoDuration,
    String? content,
    bool isFree = false,
  }) async {
    return await _lessonService.createLesson(
      moduleId: moduleId,
      courseId: courseId,
      title: title,
      description: description,
      orderNumber: orderNumber,
      lessonType: lessonType,
      videoUrl: videoUrl,
      videoDuration: videoDuration,
      content: content,
      isFree: isFree,
    );
  }

  Future<bool> updateLesson({
    required String lessonId,
    String? title,
    String? description,
    int? orderNumber,
    LessonType? lessonType,
    String? videoUrl,
    int? videoDuration,
    String? content,
    bool? isFree,
  }) async {
    return await _lessonService.updateLesson(
      lessonId: lessonId,
      title: title,
      description: description,
      orderNumber: orderNumber,
      lessonType: lessonType,
      videoUrl: videoUrl,
      videoDuration: videoDuration,
      content: content,
      isFree: isFree,
    );
  }

  Future<bool> deleteLesson(String lessonId) async {
    return await _lessonService.deleteLesson(lessonId);
  }

  // ============================================
  // الامتحانات
  // ============================================

  Future<List<Exam>> getCourseExams(String courseId) async {
    return await _examService.getCourseExams(courseId);
  }

  Future<Exam?> getExam(String examId) async {
    return await _examService.getExam(examId);
  }

  Future<Exam?> createExam({
    required String courseId,
    required String title,
    String? description,
    int? totalQuestions,
    int? passingScore,
    int? durationMinutes,
    bool allowRetake = true,
    int maxAttempts = 3,
  }) async {
    return await _examService.createExam(
      courseId: courseId,
      title: title,
      description: description,
      totalQuestions: totalQuestions,
      passingScore: passingScore,
      durationMinutes: durationMinutes,
      allowRetake: allowRetake,
      maxAttempts: maxAttempts,
    );
  }

  Future<bool> updateExam({
    required String examId,
    String? title,
    String? description,
    int? totalQuestions,
    int? passingScore,
    int? durationMinutes,
    ExamStatus? status,
    bool? allowRetake,
    int? maxAttempts,
  }) async {
    return await _examService.updateExam(
      examId: examId,
      title: title,
      description: description,
      totalQuestions: totalQuestions,
      passingScore: passingScore,
      durationMinutes: durationMinutes,
      status: status,
      allowRetake: allowRetake,
      maxAttempts: maxAttempts,
    );
  }

  Future<bool> deleteExam(String examId) async {
    return await _examService.deleteExam(examId);
  }

  Future<List<ExamQuestion>> getExamQuestions(String examId) async {
    return await _examService.getExamQuestions(examId);
  }

  Future<ExamQuestion?> addExamQuestion({
    required String examId,
    required String questionText,
    required QuestionType questionType,
    List<String>? options,
    String? correctAnswer,
    int points = 1,
    int? orderNumber,
  }) async {
    return await _examService.addQuestion(
      examId: examId,
      questionText: questionText,
      questionType: questionType,
      options: options,
      correctAnswer: correctAnswer,
      points: points,
      orderNumber: orderNumber,
    );
  }

  Future<List<ExamResult>> getExamResults(String examId) async {
    return await _examService.getExamResults(examId);
  }

  // ============================================
  // التسجيل والطلاب
  // ============================================

  Future<List<Enrollment>> getStudents() async {
    // الحصول على جميع التسجيلات لكورسات المزود
    final user = await getUser();
    if (user == null) return [];

    final courses = await getCourses();
    final allEnrollments = <Enrollment>[];

    for (final course in courses) {
      final enrollments = await _enrollmentService.getCourseStudents(course.id);
      for (final e in enrollments) {
        allEnrollments.add(Enrollment.fromJson(e));
      }
    }

    return allEnrollments;
  }

  Future<Enrollment?> getStudentById(String studentId) async {
    // هذه الدالة تحتاج تعديل - يجب الحصول على بيانات المستخدم
    return null;
  }

  Future<bool> addStudent(Enrollment student) async {
    return await _enrollmentService.enrollCourse(
      studentId: student.studentId,
      courseId: student.courseId,
    );
  }

  Future<bool> updateStudent(Enrollment student) async {
    return await _enrollmentService.updateProgress(
      studentId: student.studentId,
      courseId: student.courseId,
      percentage: student.completionPercentage,
    );
  }

  Future<List<Enrollment>> getCourseStudents(String courseId) async {
    final data = await _enrollmentService.getCourseStudents(courseId);
    return data.map((e) => Enrollment.fromJson(e)).toList();
  }

  Future<bool> enrollStudent({
    required String studentId,
    required String courseId,
  }) async {
    return await _enrollmentService.enrollCourse(
      studentId: studentId,
      courseId: courseId,
    );
  }

  Future<double> getStudentProgress(String studentId, String courseId) async {
    return await _enrollmentService.getProgress(studentId, courseId);
  }

  // ============================================
  // الشهادات
  // ============================================

  Future<List<Certificate>> getCertificates() async {
    final user = await getUser();
    if (user == null) return [];
    return await _certificateService.getProviderCertificates(user.id);
  }

  Future<Certificate?> getCertificateById(String certificateId) async {
    return await _certificateService.getCertificate(certificateId);
  }

  Future<bool> addCertificate(Certificate certificate) async {
    final created = await _certificateService.issueCertificate(
      courseId: certificate.courseId,
      studentId: certificate.studentId,
      providerId: certificate.providerId,
    );
    return created != null;
  }

  Future<bool> updateCertificate(Certificate certificate) async {
    // الشهادات لا يتم تحديثها عادةً
    return false;
  }

  Future<Certificate?> issueCertificate({
    required String courseId,
    required String studentId,
    required String providerId,
  }) async {
    return await _certificateService.issueCertificate(
      courseId: courseId,
      studentId: studentId,
      providerId: providerId,
    );
  }

  // ============================================
  // الإشعارات
  // ============================================

  Future<List<Notification>> getNotifications() async {
    final user = await getUser();
    if (user == null) return [];
    return await _notificationService.getUserNotifications(user.id);
  }

  Future<int> getUnreadNotificationsCount() async {
    final user = await getUser();
    if (user == null) return 0;
    return await _notificationService.getUnreadCount(user.id);
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    return await _notificationService.markAsRead(notificationId);
  }

  // ============================================
  // المدفوعات
  // ============================================

  Future<List<Payment>> getPayments() async {
    final user = await getUser();
    if (user == null) return [];
    return await _paymentService.getProviderPayments(user.id);
  }

  Future<double> getTotalEarnings() async {
    final user = await getUser();
    if (user == null) return 0;
    return await _paymentService.getTotalEarnings(user.id);
  }

  // ============================================
  // الإحصائيات
  // ============================================

  Future<Map<String, dynamic>> getStatistics() async {
    final user = await getUser();
    if (user == null) return {};

    final courses = await getCourses();
    final certificates = await getCertificates();
    final payments = await getPayments();

    final totalCourses = courses.length;
    final publishedCourses =
        courses.where((c) => c.status == CourseStatus.published).length;
    final draftCourses =
        courses.where((c) => c.status == CourseStatus.draft).length;

    final totalStudents =
        courses.fold<int>(0, (sum, c) => sum + c.studentsCount);
    final totalEarnings = payments
        .where((p) => p.status == PaymentStatus.completed)
        .fold<double>(0, (sum, p) => sum + p.amount);

    final totalCertificates = certificates.length;
    final averageRating = courses.isEmpty
        ? 0.0
        : courses.fold<double>(0, (sum, c) => sum + c.rating) / courses.length;

    return {
      'totalCourses': totalCourses,
      'publishedCourses': publishedCourses,
      'draftCourses': draftCourses,
      'totalStudents': totalStudents,
      'totalEarnings': totalEarnings,
      'totalCertificates': totalCertificates,
      'averageRating': averageRating,
    };
  }

  // ============================================
  // التخزين
  // ============================================

  Future<String?> uploadVideo({
    required dynamic videoFile,
    required String courseId,
    required String lessonId,
  }) async {
    return await _storageService.uploadVideo(
      videoFile: videoFile,
      courseId: courseId,
      lessonId: lessonId,
    );
  }

  Future<String?> uploadImage({
    required dynamic imageFile,
    required String courseId,
    String? type,
  }) async {
    return await _storageService.uploadImage(
      imageFile: imageFile,
      courseId: courseId,
      type: type,
    );
  }

  Future<String?> uploadFile({
    required dynamic file,
    required String courseId,
    required String lessonId,
    required String fileType,
  }) async {
    return await _storageService.uploadFile(
      file: file,
      courseId: courseId,
      lessonId: lessonId,
      fileType: fileType,
    );
  }

  Future<bool> deleteFile({
    required String bucket,
    required String filePath,
  }) async {
    return await _storageService.deleteFile(
      bucket: bucket,
      filePath: filePath,
    );
  }

  // ============================================
  // الإعدادات
  // ============================================

  Future<AppSettings> getSettings() async {
    final user = await getUser();
    if (user == null) {
      return AppSettings(id: '', userId: '', updatedAt: DateTime.now());
    }
    final settings = await _settingsService.getUserSettings(user.id);
    return settings ?? await _settingsService.createDefaultSettings(user.id);
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _settingsService.updateSettings(settings);
  }
}
