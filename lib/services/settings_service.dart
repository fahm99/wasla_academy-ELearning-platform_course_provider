import 'supabase_service.dart';
import '../models/app_settings.dart';
import '../config/supabase_config.dart';

/// خدمة إدارة الإعدادات
class SettingsService {
  final SupabaseService _supabaseService = SupabaseService();

  /// الحصول على إعدادات المستخدم
  Future<AppSettings?> getUserSettings(String userId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.appSettingsTable,
        filters: {'user_id': userId},
        limit: 1,
      );
      if (data.isEmpty) return null;
      return AppSettings.fromJson(data[0]);
    } catch (e) {
      return null;
    }
  }

  /// إنشاء إعدادات افتراضية
  Future<AppSettings> createDefaultSettings(String userId) async {
    try {
      final data = await _supabaseService.insert(
        SupabaseConfig.appSettingsTable,
        {
          'user_id': userId,
          'theme': 'light',
          'language': 'ar',
          'notifications_enabled': true,
          'email_notifications': true,
        },
      );
      return AppSettings.fromJson(data);
    } catch (e) {
      return AppSettings(
        id: '',
        userId: userId,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// تحديث الإعدادات
  Future<bool> updateSettings(AppSettings settings) async {
    try {
      if (settings.id.isEmpty) {
        await _supabaseService.insert(
          SupabaseConfig.appSettingsTable,
          settings.toJson(),
        );
      } else {
        await _supabaseService.update(
          SupabaseConfig.appSettingsTable,
          settings.id,
          {
            'theme': settings.theme,
            'language': settings.language,
            'notifications_enabled': settings.notificationsEnabled,
            'email_notifications': settings.emailNotifications,
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
