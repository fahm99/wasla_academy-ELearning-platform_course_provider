import 'supabase_service.dart';
import '../models/notification.dart';
import '../config/supabase_config.dart';

/// خدمة إدارة الإشعارات
class NotificationService {
  final SupabaseService _supabaseService = SupabaseService();

  /// الحصول على إشعارات المستخدم
  Future<List<Notification>> getUserNotifications(String userId,
      {int? limit, bool? unreadOnly}) async {
    try {
      var filters = <String, dynamic>{'user_id': userId};
      if (unreadOnly == true) {
        filters['is_read'] = false;
      }

      final data = await _supabaseService.query(
        SupabaseConfig.notificationsTable,
        filters: filters,
        orderBy: 'created_at',
        ascending: false,
        limit: limit ?? 50,
      );
      return data.map((e) => Notification.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// الحصول على عدد الإشعارات غير المقروءة
  Future<int> getUnreadCount(String userId) async {
    try {
      return await _supabaseService.count(
        SupabaseConfig.notificationsTable,
        filters: {
          'user_id': userId,
          'is_read': false,
        },
      );
    } catch (e) {
      return 0;
    }
  }

  /// إنشاء إشعار
  Future<Notification?> createNotification({
    required String userId,
    required String title,
    String? message,
    required NotificationType type,
    String? relatedId,
  }) async {
    try {
      final data = await _supabaseService.insert(
        SupabaseConfig.notificationsTable,
        {
          'user_id': userId,
          'title': title,
          'message': message,
          'type': type.name,
          'related_id': relatedId,
        },
      );
      return Notification.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// تحديد الإشعار كمقروء
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _supabaseService.update(
        SupabaseConfig.notificationsTable,
        notificationId,
        {'is_read': true},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// تحديد جميع الإشعارات كمقروءة
  Future<bool> markAllAsRead(String userId) async {
    try {
      final notifications =
          await getUserNotifications(userId, unreadOnly: true);
      for (final notification in notifications) {
        await markAsRead(notification.id);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف إشعار
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _supabaseService.delete(
        SupabaseConfig.notificationsTable,
        notificationId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف جميع الإشعارات
  Future<bool> deleteAllNotifications(String userId) async {
    try {
      final notifications = await getUserNotifications(userId);
      for (final notification in notifications) {
        await deleteNotification(notification.id);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== إشعارات مخصصة ==========

  /// إشعار تسجيل طالب جديد
  Future<void> notifyNewStudent({
    required String providerId,
    required String studentName,
    required String courseName,
  }) async {
    await createNotification(
      userId: providerId,
      title: 'طالب جديد',
      message: 'انضم $studentName إلى كورس $courseName',
      type: NotificationType.course,
    );
  }

  /// إشعار إكمال كورس
  Future<void> notifyCourseCompleted({
    required String providerId,
    required String studentName,
    required String courseName,
  }) async {
    await createNotification(
      userId: providerId,
      title: 'إكمال كورس',
      message: 'أكمل $studentName كورس $courseName',
      type: NotificationType.course,
    );
  }

  /// إشعار تقييم جديد
  Future<void> notifyNewReview({
    required String providerId,
    required String studentName,
    required String courseName,
    required int rating,
  }) async {
    await createNotification(
      userId: providerId,
      title: 'تقييم جديد',
      message: 'قام $studentName بتقييم كورس $courseName بـ $rating نجوم',
      type: NotificationType.course,
    );
  }

  /// إشعار دفعة جديدة
  Future<void> notifyNewPayment({
    required String providerId,
    required double amount,
    required String courseName,
  }) async {
    await createNotification(
      userId: providerId,
      title: 'دفعة جديدة',
      message: 'تم استلام دفعة بقيمة $amount ريال من كورس $courseName',
      type: NotificationType.payment,
    );
  }

  /// إشعار إصدار شهادة
  Future<void> notifyCertificateIssued({
    required String studentId,
    required String courseName,
  }) async {
    await createNotification(
      userId: studentId,
      title: 'شهادة جديدة',
      message: 'تم إصدار شهادتك في كورس $courseName',
      type: NotificationType.certificate,
    );
  }
}
