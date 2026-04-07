import '../services/index.dart';
import '../models/index.dart';

/// Repository الرئيسي للتعامل مع Supabase
class SupabaseRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  final CourseService _courseService = CourseService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  final StorageService _storageService = StorageService();

  // ============================================
  // المصادقة
  // ============================================

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    return await _authService.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
      userType: userType,
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return await _authService.login(email: email, password: password);
  }

  Future<bool> logout() async {
    return await _authService.logout();
  }

  Future<User?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  bool isLoggedIn() {
    return _authService.isLoggedIn();
  }

  // ============================================
  // الكورسات
  // ============================================

  Future<List<Course>> getPublishedCourses({
    int? limit,
    int? offset,
    String? category,
    String? level,
  }) async {
    return await _courseService.getPublishedCourses(
      limit: limit,
      offset: offset,
      category: category,
      level: level,
    );
  }

  Future<List<Course>> getProviderCourses(String providerId) async {
    return await _courseService.getProviderCourses(providerId);
  }

  Future<Course?> getCourseDetails(String courseId) async {
    return await _courseService.getCourseDetails(courseId);
  }

  Future<List<Course>> searchCourses(String query) async {
    return await _courseService.searchCourses(query);
  }

  Future<Course?> createCourse({
    required String providerId,
    required String title,
    required String description,
    String? category,
    String? level,
    double? price,
    int? durationHours,
    String? thumbnailUrl,
    String? coverImageUrl,
  }) async {
    return await _courseService.createCourse(
      providerId: providerId,
      title: title,
      description: description,
      category: category,
      level: level,
      price: price,
      durationHours: durationHours,
      thumbnailUrl: thumbnailUrl,
      coverImageUrl: coverImageUrl,
    );
  }

  Future<bool> updateCourse({
    required String courseId,
    String? title,
    String? description,
    String? category,
    String? level,
    double? price,
    int? durationHours,
    String? thumbnailUrl,
    String? coverImageUrl,
    String? status,
  }) async {
    return await _courseService.updateCourse(
      courseId: courseId,
      title: title,
      description: description,
      category: category,
      level: level,
      price: price,
      durationHours: durationHours,
      thumbnailUrl: thumbnailUrl,
      coverImageUrl: coverImageUrl,
      status: status,
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

  // ============================================
  // التسجيل والالتحاق
  // ============================================

  Future<bool> enrollCourse({
    required String studentId,
    required String courseId,
  }) async {
    return await _enrollmentService.enrollCourse(
      studentId: studentId,
      courseId: courseId,
    );
  }

  Future<List<Map<String, dynamic>>> getStudentCourses(String studentId) async {
    return await _enrollmentService.getStudentCourses(studentId);
  }

  Future<List<Map<String, dynamic>>> getCourseStudents(String courseId) async {
    return await _enrollmentService.getCourseStudents(courseId);
  }

  Future<double> getProgress(String studentId, String courseId) async {
    return await _enrollmentService.getProgress(studentId, courseId);
  }

  Future<bool> updateProgress({
    required String studentId,
    required String courseId,
    required int percentage,
  }) async {
    return await _enrollmentService.updateProgress(
      studentId: studentId,
      courseId: courseId,
      percentage: percentage,
    );
  }

  Future<bool> completeCourse(String studentId, String courseId) async {
    return await _enrollmentService.completeCourse(studentId, courseId);
  }

  Future<bool> dropCourse(String studentId, String courseId) async {
    return await _enrollmentService.dropCourse(studentId, courseId);
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
  // الاستعلامات العامة
  // ============================================

  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    return await _supabaseService.query(
      table,
      select: select,
      filters: filters,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    return await _supabaseService.insert(table, data);
  }

  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _supabaseService.update(table, id, data);
  }

  Future<void> delete(String table, String id) async {
    return await _supabaseService.delete(table, id);
  }
}
