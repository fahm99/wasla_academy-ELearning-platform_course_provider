import 'package:course_provider/data/services/supabase_service.dart';
import '../models/module.dart';
import '../../core/config/supabase_config.dart';

/// خدمة إدارة الوحدات
class ModuleService {
  final SupabaseService _supabaseService = SupabaseService();

  /// الحصول على وحدات الكورس
  Future<List<Module>> getCourseModules(String courseId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.modulesTable,
        filters: {'course_id': courseId},
        orderBy: 'order_number',
        ascending: true,
      );
      return data.map((e) => Module.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// الحصول على وحدة واحدة
  Future<Module?> getModule(String moduleId) async {
    try {
      final data = await _supabaseService.getOne(
        SupabaseConfig.modulesTable,
        moduleId,
      );
      if (data == null) return null;
      return Module.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// إنشاء وحدة جديدة
  Future<Module?> createModule({
    required String courseId,
    required String title,
    String? description,
    required int orderNumber,
  }) async {
    try {
      final data = await _supabaseService.insert(
        SupabaseConfig.modulesTable,
        {
          'course_id': courseId,
          'title': title,
          'description': description,
          'order_number': orderNumber,
        },
      );
      return Module.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// تحديث الوحدة
  Future<bool> updateModule({
    required String moduleId,
    String? title,
    String? description,
    int? orderNumber,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (orderNumber != null) updateData['order_number'] = orderNumber;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabaseService.update(
        SupabaseConfig.modulesTable,
        moduleId,
        updateData,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف الوحدة
  Future<bool> deleteModule(String moduleId) async {
    try {
      await _supabaseService.delete(SupabaseConfig.modulesTable, moduleId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// إعادة ترتيب الوحدات
  Future<bool> reorderModules(List<String> moduleIds) async {
    try {
      for (int i = 0; i < moduleIds.length; i++) {
        await _supabaseService.update(
          SupabaseConfig.modulesTable,
          moduleIds[i],
          {'order_number': i + 1},
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
