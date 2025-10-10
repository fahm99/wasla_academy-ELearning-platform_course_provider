import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/index.dart';

class Repository {
  static const String _userKey = 'user';
  static const String _coursesKey = 'courses';
  static const String _studentsKey = 'students';
  static const String _certificatesKey = 'certificates';

  static const String _settingsKey = 'settings';
  static const String _isLoggedInKey = 'isLoggedIn';

  // الحصول على SharedPreferences
  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // ===== إدارة المصادقة =====

  Future<bool> login(String email, String password) async {
    try {
      // محاكاة تسجيل الدخول
      await Future.delayed(const Duration(seconds: 2));

      // التحقق من بيانات الاعتماد (محاكاة)
      if (email == 'provider@wasla.com' && password == '123456') {
        final user = User(
          id: '1',
          name: 'د. أحمد اليافعي',
          email: email,
          phone: '+966501234567',
          avatar: 'https://via.placeholder.com/150',
          profileImage:
              'assets/passport.jpg', // استخدام الصورة الموجودة في المشروع
          type: UserType.provider,
          createdAt: DateTime.now(),
          coursesCount: 8,
          studentsCount: 1245,
          rating: 4.6,
        );

        await saveUser(user);
        await setLoggedIn(true);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(
      String name, String email, String password, String phone) async {
    try {
      // محاكاة التسجيل
      await Future.delayed(const Duration(seconds: 2));

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        type: UserType.provider,
        createdAt: DateTime.now(),
        coursesCount: 0,
        studentsCount: 0,
        rating: 0.0,
      );

      await saveUser(user);
      await setLoggedIn(true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_isLoggedInKey, value);
  }

  // ===== إدارة المستخدم =====

  Future<void> saveUser(User user) async {
    final prefs = await _prefs;
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await _prefs;
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    await saveUser(user);
  }

  // ===== إدارة الدورات =====

  Future<void> saveCourses(List<Course> courses) async {
    final prefs = await _prefs;
    final coursesJson = courses.map((course) => course.toJson()).toList();
    await prefs.setString(_coursesKey, jsonEncode(coursesJson));
  }

  Future<List<Course>> getCourses() async {
    final prefs = await _prefs;
    final coursesJson = prefs.getString(_coursesKey);
    if (coursesJson != null) {
      final List<dynamic> coursesList = jsonDecode(coursesJson);
      return coursesList.map((course) => Course.fromJson(course)).toList();
    }
    return [];
  }

  Future<void> addCourse(Course course) async {
    final courses = await getCourses();
    courses.add(course);
    await saveCourses(courses);
  }

  Future<void> updateCourse(Course course) async {
    final courses = await getCourses();
    final index = courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      courses[index] = course;
      await saveCourses(courses);
    }
  }

  Future<void> deleteCourse(String courseId) async {
    final courses = await getCourses();
    courses.removeWhere((course) => course.id == courseId);
    await saveCourses(courses);
  }

  Future<Course?> getCourseById(String courseId) async {
    final courses = await getCourses();
    try {
      return courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Course>> searchCourses(String query) async {
    final courses = await getCourses();
    if (query.isEmpty) return courses;

    return courses.where((course) {
      return course.title.toLowerCase().contains(query.toLowerCase()) ||
          course.description.toLowerCase().contains(query.toLowerCase()) ||
          course.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<List<Course>> filterCourses({
    CourseStatus? status,
    CourseLevel? level,
    String? category,
    bool? isFree,
  }) async {
    final courses = await getCourses();

    return courses.where((course) {
      if (status != null && course.status != status) return false;
      if (level != null && course.level != level) return false;
      if (category != null && course.category != category) return false;
      if (isFree != null && course.isFree != isFree) return false;
      return true;
    }).toList();
  }

  // ===== إدارة الطلاب =====

  Future<void> saveStudents(List<Student> students) async {
    final prefs = await _prefs;
    final studentsJson = students.map((student) => student.toJson()).toList();
    await prefs.setString(_studentsKey, jsonEncode(studentsJson));
  }

  Future<List<Student>> getStudents() async {
    final prefs = await _prefs;
    final studentsJson = prefs.getString(_studentsKey);
    if (studentsJson != null) {
      final List<dynamic> studentsList = jsonDecode(studentsJson);
      return studentsList.map((student) => Student.fromJson(student)).toList();
    }
    return [];
  }

  Future<void> addStudent(Student student) async {
    final students = await getStudents();
    students.add(student);
    await saveStudents(students);
  }

  Future<void> updateStudent(Student student) async {
    final students = await getStudents();
    final index = students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      students[index] = student;
      await saveStudents(students);
    }
  }

  Future<Student?> getStudentById(String studentId) async {
    final students = await getStudents();
    try {
      return students.firstWhere((student) => student.id == studentId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Student>> searchStudents(String query) async {
    final students = await getStudents();
    if (query.isEmpty) return students;

    return students.where((student) {
      return student.name.toLowerCase().contains(query.toLowerCase()) ||
          student.email.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // ===== إدارة الشهادات =====

  Future<void> saveCertificates(List<Certificate> certificates) async {
    final prefs = await _prefs;
    final certificatesJson = certificates.map((cert) => cert.toJson()).toList();
    await prefs.setString(_certificatesKey, jsonEncode(certificatesJson));
  }

  Future<List<Certificate>> getCertificates() async {
    final prefs = await _prefs;
    final certificatesJson = prefs.getString(_certificatesKey);
    if (certificatesJson != null) {
      final List<dynamic> certificatesList = jsonDecode(certificatesJson);
      return certificatesList
          .map((cert) => Certificate.fromJson(cert))
          .toList();
    }
    return [];
  }

  Future<void> addCertificate(Certificate certificate) async {
    final certificates = await getCertificates();
    certificates.add(certificate);
    await saveCertificates(certificates);
  }

  Future<void> updateCertificate(Certificate certificate) async {
    final certificates = await getCertificates();
    final index = certificates.indexWhere((c) => c.id == certificate.id);
    if (index != -1) {
      certificates[index] = certificate;
      await saveCertificates(certificates);
    }
  }

  Future<Certificate?> getCertificateById(String certificateId) async {
    final certificates = await getCertificates();
    try {
      return certificates.firstWhere((cert) => cert.id == certificateId);
    } catch (e) {
      return null;
    }
  }

  // ===== إدارة الإحصائيات =====

  // ===== إحصائيات بسيطة للداشبورد =====

  Future<Map<String, int>> getBasicStatistics() async {
    final courses = await getCourses();
    final students = await getStudents();
    final certificates = await getCertificates();

    final totalCourses = courses.length;
    final publishedCourses =
        courses.where((c) => c.status == CourseStatus.published).length;
    final totalStudents = students.length;
    final activeStudents =
        students.where((s) => s.status == StudentStatus.active).length;
    final totalCertificates = certificates.length;

    return {
      'totalCourses': totalCourses,
      'publishedCourses': publishedCourses,
      'totalStudents': totalStudents,
      'activeStudents': activeStudents,
      'totalCertificates': totalCertificates,
    };
  }

  // ===== إدارة الإعدادات =====

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await _prefs;
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<AppSettings> getSettings() async {
    final prefs = await _prefs;
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      return AppSettings.fromJson(jsonDecode(settingsJson));
    }
    return const AppSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    await saveSettings(settings);
  }
}
