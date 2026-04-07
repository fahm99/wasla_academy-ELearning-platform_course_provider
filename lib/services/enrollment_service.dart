import 'supabase_service.dart';
import '../config/supabase_config.dart';

/// خدمة إدارة التسجيل والالتحاق بالكورسات
class EnrollmentService {
  final SupabaseService _supabaseService = SupabaseService();

  /// الالتحاق بالكورس
  Future<bool> enrollCourse({
    required String studentId,
    required String courseId,
  }) async {
    try {
      // التحقق من عدم التسجيل مسبقاً
      final existing = await _supabaseService.query(
        SupabaseConfig.enrollmentsTable,
        filters: {
          'student_id': studentId,
          'course_id': courseId,
        },
      );

      if (existing.isNotEmpty) {
        print('⚠️ الطالب مسجل بالفعل في هذا الكورس');
        return false;
      }

      // إضافة التسجيل
      await _supabaseService.insert(
        SupabaseConfig.enrollmentsTable,
        {
          'student_id': studentId,
          'course_id': courseId,
          'enrollment_date': DateTime.now().toIso8601String(),
          'status': 'active',
          'completion_percentage': 0,
        },
      );

      print('✅ تم الالتحاق بالكورس بنجاح');
      return true;
    } catch (e) {
      print('❌ خطأ في الالتحاق بالكورس: $e');
      return false;
    }
  }

  /// الحصول على كورسات الطالب
  Future<List<Map<String, dynamic>>> getStudentCourses(String studentId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.enrollmentsTable,
        filters: {'student_id': studentId},
        orderBy: 'enrollment_date',
        ascending: false,
      );

      return data;
    } catch (e) {
      print('❌ خطأ في الحصول على كورسات الطالب: $e');
      return [];
    }
  }

  /// الحصول على طلاب الكورس
  Future<List<Map<String, dynamic>>> getCourseStudents(String courseId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.enrollmentsTable,
        filters: {'course_id': courseId},
        orderBy: 'enrollment_date',
        ascending: false,
      );

      return data;
    } catch (e) {
      print('❌ خطأ في الحصول على طلاب الكورس: $e');
      return [];
    }
  }

  /// الحصول على تقدم الطالب في الكورس
  Future<double> getProgress(String studentId, String courseId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.enrollmentsTable,
        filters: {
          'student_id': studentId,
          'course_id': courseId,
        },
      );

      if (data.isEmpty) return 0;
      return (data[0]['completion_percentage'] as num).toDouble();
    } catch (e) {
      print('❌ خطأ في الحصول على التقدم: $e');
      return 0;
    }
  }

  /// تحديث التقدم
  Future<bool> updateProgress({
    required String studentId,
    required String courseId,
    required int percentage,
  }) async {
    try {
      // الحصول على معرف التسجيل
      final enrollments = await _supabaseService.query(
        SupabaseConfig.enrollmentsTable,
        filters: {
          'student_id': studentId,
          'course_id': courseId,
        },
      );

      if (enrollments.isEmpty) {
        print('⚠️ لم يتم العثور على التسجيل');
        return false;
      }

      final enrollmentId = enrollments[0]['id'];

      // تحديث التقدم
      await _supabaseService.update(
        SupabaseConfig.enrollmentsTable,
        enrollmentId,
        {
          'completion_percentage': percentage,
          'last_accessed': DateTime.now().toIso8601String(),
        },
      );

      // إذا كان التقدم 100%، تحديث الحالة إلى مكتمل
      if (percentage >= 100) {
        await _supabaseService.update(
          SupabaseConfig.enrollmentsTable,
          enrollmentId,
          {'status': 'completed'},
        );
      }

      print('✅ تم تحديث التقدم بنجاح');
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث التقدم: $e');
      return false;
    }
  }

  /// إنهاء الكورس
  Future<bool> completeCourse(String studentId, String courseId) async {
    try {
      final enrollments = await _supabaseService.query(
        SupabaseConfig.enrollmentsTable,
        filters: {
          'student_id': studentId,
          'course_id': courseId,
        },
      );

      if (enrollments.isEmpty) return false;

      final enrollmentId = enrollments[0]['id'];

      await _supabaseService.update(
        SupabaseConfig.enrollmentsTable,
        enrollmentId,
        {
          'status': 'completed',
          'completion_percentage': 100,
        },
      );

      print('✅ تم إنهاء الكورس بنجاح');
      return true;
    } catch (e) {
      print('❌ خطأ في إنهاء الكورس: $e');
      return false;
    }
  }

  /// ترك الكورس
  Future<bool> dropCourse(String studentId, String courseId) async {
    try {
      final enrollments = await _supabaseService.query(
        SupabaseConfig.enrollmentsTable,
        filters: {
          'student_id': studentId,
          'course_id': courseId,
        },
      );

      if (enrollments.isEmpty) return false;

      final enrollmentId = enrollments[0]['id'];

      await _supabaseService.update(
        SupabaseConfig.enrollmentsTable,
        enrollmentId,
        {'status': 'dropped'},
      );

      print('✅ تم ترك الكورس بنجاح');
      return true;
    } catch (e) {
      print('❌ خطأ في ترك الكورس: $e');
      return false;
    }
  }

  /// الحصول على حالة التسجيل
  Future<String?> getEnrollmentStatus(String studentId, String courseId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.enrollmentsTable,
        filters: {
          'student_id': studentId,
          'course_id': courseId,
        },
      );

      if (data.isEmpty) return null;
      return data[0]['status'];
    } catch (e) {
      print('❌ خطأ في الحصول على حالة التسجيل: $e');
      return null;
    }
  }

  /// التحقق من التسجيل
  Future<bool> isEnrolled(String studentId, String courseId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.enrollmentsTable,
        filters: {
          'student_id': studentId,
          'course_id': courseId,
        },
      );

      return data.isNotEmpty;
    } catch (e) {
      print('❌ خطأ في التحقق من التسجيل: $e');
      return false;
    }
  }

  /// الحصول على عدد الطلاب المسجلين
  Future<int> getEnrolledStudentsCount(String courseId) async {
    try {
      return await _supabaseService.count(
        SupabaseConfig.enrollmentsTable,
        filters: {'course_id': courseId},
      );
    } catch (e) {
      print('❌ خطأ في الحصول على عدد الطلاب: $e');
      return 0;
    }
  }

  /// الحصول على عدد الكورسات المسجلة
  Future<int> getEnrolledCoursesCount(String studentId) async {
    try {
      return await _supabaseService.count(
        SupabaseConfig.enrollmentsTable,
        filters: {'student_id': studentId},
      );
    } catch (e) {
      print('❌ خطأ في الحصول على عدد الكورسات: $e');
      return 0;
    }
  }

  /// الحصول على الكورسات المكتملة
  Future<List<Map<String, dynamic>>> getCompletedCourses(
      String studentId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.enrollmentsTable,
        filters: {
          'student_id': studentId,
          'status': 'completed',
        },
      );

      return data;
    } catch (e) {
      print('❌ خطأ في الحصول على الكورسات المكتملة: $e');
      return [];
    }
  }

  /// الحصول على الكورسات النشطة
  Future<List<Map<String, dynamic>>> getActiveCourses(String studentId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.enrollmentsTable,
        filters: {
          'student_id': studentId,
          'status': 'active',
        },
      );

      return data;
    } catch (e) {
      print('❌ خطأ في الحصول على الكورسات النشطة: $e');
      return [];
    }
  }

  /// تحديث آخر وقت وصول
  Future<bool> updateLastAccessed(String studentId, String courseId) async {
    try {
      final enrollments = await _supabaseService.query(
        SupabaseConfig.enrollmentsTable,
        filters: {
          'student_id': studentId,
          'course_id': courseId,
        },
      );

      if (enrollments.isEmpty) return false;

      final enrollmentId = enrollments[0]['id'];

      await _supabaseService.update(
        SupabaseConfig.enrollmentsTable,
        enrollmentId,
        {'last_accessed': DateTime.now().toIso8601String()},
      );

      return true;
    } catch (e) {
      print('❌ خطأ في تحديث آخر وقت وصول: $e');
      return false;
    }
  }
}
