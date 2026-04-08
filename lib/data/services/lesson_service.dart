import 'package:course_provider/data/services/supabase_service.dart';
import '../models/lesson.dart';
import '../models/lesson_resource.dart';
import '../../core/config/supabase_config.dart';

/// خدمة إدارة الدروس
class LessonService {
  final SupabaseService _supabaseService = SupabaseService();

  /// الحصول على دروس الوحدة
  Future<List<Lesson>> getModuleLessons(String moduleId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.lessonsTable,
        filters: {'module_id': moduleId},
        orderBy: 'order_number',
        ascending: true,
      );
      return data.map((e) => Lesson.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// الحصول على دروس الكورس
  Future<List<Lesson>> getCourseLessons(String courseId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.lessonsTable,
        filters: {'course_id': courseId},
        orderBy: 'order_number',
        ascending: true,
      );
      return data.map((e) => Lesson.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// الحصول على درس واحد
  Future<Lesson?> getLesson(String lessonId) async {
    try {
      final data = await _supabaseService.getOne(
        SupabaseConfig.lessonsTable,
        lessonId,
      );
      if (data == null) return null;
      return Lesson.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// إنشاء درس جديد
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
    try {
      final data = await _supabaseService.insert(
        SupabaseConfig.lessonsTable,
        {
          'module_id': moduleId,
          'course_id': courseId,
          'title': title,
          'description': description,
          'order_number': orderNumber,
          'lesson_type': lessonType?.name ?? 'video',
          'video_url': videoUrl,
          'video_duration': videoDuration,
          'content': content,
          'is_free': isFree,
        },
      );
      return Lesson.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// تحديث الدرس
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
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (orderNumber != null) updateData['order_number'] = orderNumber;
      if (lessonType != null) updateData['lesson_type'] = lessonType.name;
      if (videoUrl != null) updateData['video_url'] = videoUrl;
      if (videoDuration != null) updateData['video_duration'] = videoDuration;
      if (content != null) updateData['content'] = content;
      if (isFree != null) updateData['is_free'] = isFree;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabaseService.update(
        SupabaseConfig.lessonsTable,
        lessonId,
        updateData,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف الدرس
  Future<bool> deleteLesson(String lessonId) async {
    try {
      await _supabaseService.delete(SupabaseConfig.lessonsTable, lessonId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// إعادة ترتيب الدروس
  Future<bool> reorderLessons(List<String> lessonIds) async {
    try {
      for (int i = 0; i < lessonIds.length; i++) {
        await _supabaseService.update(
          SupabaseConfig.lessonsTable,
          lessonIds[i],
          {'order_number': i + 1},
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== موارد الدرس ==========

  /// الحصول على موارد الدرس
  Future<List<LessonResource>> getLessonResources(String lessonId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.lessonResourcesTable,
        filters: {'lesson_id': lessonId},
      );
      return data.map((e) => LessonResource.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// إضافة مورد للدرس
  Future<LessonResource?> addLessonResource({
    required String lessonId,
    required String fileName,
    required String fileUrl,
    required FileType fileType,
    int? fileSize,
  }) async {
    try {
      final data = await _supabaseService.insert(
        SupabaseConfig.lessonResourcesTable,
        {
          'lesson_id': lessonId,
          'file_name': fileName,
          'file_url': fileUrl,
          'file_type': fileType.name,
          'file_size': fileSize,
        },
      );
      return LessonResource.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// حذف مورد الدرس
  Future<bool> deleteLessonResource(String resourceId) async {
    try {
      await _supabaseService.delete(
        SupabaseConfig.lessonResourcesTable,
        resourceId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
