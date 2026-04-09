import 'package:course_provider/data/services/supabase_service.dart';
import '../../core/config/supabase_config.dart';

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

  /// الحصول على طلاب الكورس مع بياناتهم الكاملة
  Future<List<Map<String, dynamic>>> getCourseStudentsWithDetails(
      String courseId) async {
    try {
      final supabase = _supabaseService.client;

      final data = await supabase
          .from('enrollments')
          .select('''
            *,
            users!enrollments_student_id_fkey(
              id,
              name,
              email,
              avatar_url,
              phone
            )
          ''')
          .eq('course_id', courseId)
          .order('enrollment_date', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('❌ خطأ في الحصول على طلاب الكورس: $e');
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
