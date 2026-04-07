import 'supabase_service.dart';
import '../models/course.dart';
import '../config/supabase_config.dart';

/// خدمة إدارة الكورسات
class CourseService {
  final SupabaseService _supabaseService = SupabaseService();

  /// الحصول على جميع الكورسات المنشورة
  Future<List<Course>> getPublishedCourses({
    int? limit,
    int? offset,
    String? category,
    String? level,
  }) async {
    try {
      final filters = {
        'status': 'published',
        if (category != null) 'category': category,
        if (level != null) 'level': level,
      };

      final data = await _supabaseService.query(
        SupabaseConfig.coursesTable,
        filters: filters,
        orderBy: 'created_at',
        ascending: false,
        limit: limit ?? 10,
        offset: offset ?? 0,
      );

      return data.map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على الكورسات: $e');
      return [];
    }
  }

  /// الحصول على كورسات مقدم الخدمة
  Future<List<Course>> getProviderCourses(String providerId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.coursesTable,
        filters: {'provider_id': providerId},
        orderBy: 'created_at',
        ascending: false,
      );

      return data.map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على كورسات المزود: $e');
      return [];
    }
  }

  /// الحصول على تفاصيل الكورس
  Future<Course?> getCourseDetails(String courseId) async {
    try {
      final data = await _supabaseService.getOne(
        SupabaseConfig.coursesTable,
        courseId,
      );

      if (data == null) return null;
      return Course.fromJson(data);
    } catch (e) {
      print('❌ خطأ في الحصول على تفاصيل الكورس: $e');
      return null;
    }
  }

  /// البحث عن الكورسات
  Future<List<Course>> searchCourses(String query) async {
    try {
      final data = await _supabaseService.search(
        SupabaseConfig.coursesTable,
        'title',
        query,
      );

      return data
          .where((e) => e['status'] == 'published')
          .map((e) => Course.fromJson(e))
          .toList();
    } catch (e) {
      print('❌ خطأ في البحث عن الكورسات: $e');
      return [];
    }
  }

  /// إنشاء كورس جديد
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
    try {
      final data = await _supabaseService.insert(
        SupabaseConfig.coursesTable,
        {
          'provider_id': providerId,
          'title': title,
          'description': description,
          'category': category,
          'level': level ?? 'beginner',
          'price': price ?? 0,
          'duration_hours': durationHours,
          'thumbnail_url': thumbnailUrl,
          'cover_image_url': coverImageUrl,
          'status': 'draft',
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      return Course.fromJson(data);
    } catch (e) {
      print('❌ خطأ في إنشاء الكورس: $e');
      return null;
    }
  }

  /// تحديث الكورس
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
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (level != null) updateData['level'] = level;
      if (price != null) updateData['price'] = price;
      if (durationHours != null) updateData['duration_hours'] = durationHours;
      if (thumbnailUrl != null) updateData['thumbnail_url'] = thumbnailUrl;
      if (coverImageUrl != null) updateData['cover_image_url'] = coverImageUrl;
      if (status != null) updateData['status'] = status;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabaseService.update(
        SupabaseConfig.coursesTable,
        courseId,
        updateData,
      );

      print('✅ تم تحديث الكورس بنجاح');
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث الكورس: $e');
      return false;
    }
  }

  /// حذف الكورس
  Future<bool> deleteCourse(String courseId) async {
    try {
      await _supabaseService.delete(
        SupabaseConfig.coursesTable,
        courseId,
      );

      print('✅ تم حذف الكورس بنجاح');
      return true;
    } catch (e) {
      print('❌ خطأ في حذف الكورس: $e');
      return false;
    }
  }

  /// نشر الكورس
  Future<bool> publishCourse(String courseId) async {
    return updateCourse(courseId: courseId, status: 'published');
  }

  /// إلغاء نشر الكورس
  Future<bool> unpublishCourse(String courseId) async {
    return updateCourse(courseId: courseId, status: 'draft');
  }

  /// أرشفة الكورس
  Future<bool> archiveCourse(String courseId) async {
    return updateCourse(courseId: courseId, status: 'archived');
  }

  /// الحصول على الكورسات المعلقة (للإدمن)
  Future<List<Course>> getPendingCourses() async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.coursesTable,
        filters: {'status': 'pending_review'},
        orderBy: 'created_at',
        ascending: true,
      );

      return data.map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على الكورسات المعلقة: $e');
      return [];
    }
  }

  /// الموافقة على الكورس (للإدمن)
  Future<bool> approveCourse(String courseId) async {
    return updateCourse(courseId: courseId, status: 'published');
  }

  /// رفض الكورس (للإدمن)
  Future<bool> rejectCourse(String courseId) async {
    return updateCourse(courseId: courseId, status: 'draft');
  }

  /// الحصول على إحصائيات الكورس
  Future<Map<String, dynamic>> getCourseStats(String courseId) async {
    try {
      final course = await getCourseDetails(courseId);
      if (course == null) return {};

      return {
        'students_count': course.studentsCount,
        'rating': course.rating,
        'reviews_count': course.reviewsCount,
        'price': course.price,
        'status': course.status,
      };
    } catch (e) {
      print('❌ خطأ في الحصول على إحصائيات الكورس: $e');
      return {};
    }
  }

  /// الحصول على الكورسات المميزة
  Future<List<Course>> getFeaturedCourses({int limit = 5}) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.coursesTable,
        filters: {
          'status': 'published',
          'is_featured': true,
        },
        orderBy: 'rating',
        ascending: false,
        limit: limit,
      );

      return data.map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على الكورسات المميزة: $e');
      return [];
    }
  }

  /// الحصول على الكورسات الأكثر تقييماً
  Future<List<Course>> getTopRatedCourses({int limit = 5}) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.coursesTable,
        filters: {'status': 'published'},
        orderBy: 'rating',
        ascending: false,
        limit: limit,
      );

      return data.map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على الكورسات الأكثر تقييماً: $e');
      return [];
    }
  }

  /// الحصول على الكورسات الجديدة
  Future<List<Course>> getNewCourses({int limit = 5}) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.coursesTable,
        filters: {'status': 'published'},
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
      );

      return data.map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على الكورسات الجديدة: $e');
      return [];
    }
  }

  /// تحديث عدد الطلاب
  Future<bool> updateStudentsCount(String courseId, int count) async {
    try {
      await _supabaseService.update(
        SupabaseConfig.coursesTable,
        courseId,
        {'students_count': count},
      );
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث عدد الطلاب: $e');
      return false;
    }
  }

  /// تحديث التقييم
  Future<bool> updateRating(String courseId, double rating) async {
    try {
      await _supabaseService.update(
        SupabaseConfig.coursesTable,
        courseId,
        {'rating': rating},
      );
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث التقييم: $e');
      return false;
    }
  }
}
