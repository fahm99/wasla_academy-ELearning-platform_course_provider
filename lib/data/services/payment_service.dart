import 'package:course_provider/data/services/supabase_service.dart';
import '../models/payment.dart';
import '../../core/config/supabase_config.dart';

/// خدمة إدارة المدفوعات
class PaymentService {
  final SupabaseService _supabaseService = SupabaseService();

  /// الحصول على مدفوعات مقدم الخدمة
  Future<List<Payment>> getProviderPayments(String providerId,
      {int? limit}) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.paymentsTable,
        filters: {'provider_id': providerId},
        orderBy: 'created_at',
        ascending: false,
        limit: limit ?? 50,
      );
      return data.map((e) => Payment.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// الحصول على مدفوعات الكورس
  Future<List<Payment>> getCoursePayments(String courseId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.paymentsTable,
        filters: {'course_id': courseId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((e) => Payment.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// الحصول على إجمالي الأرباح
  Future<double> getTotalEarnings(String providerId) async {
    try {
      final payments = await getProviderPayments(providerId);
      double total = 0.0;
      for (final p in payments) {
        if (p.status == PaymentStatus.completed) {
          total += p.amount;
        }
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  /// الحصول على أرباح حسب الفترة
  Future<Map<String, double>> getEarningsByPeriod(
    String providerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final payments = await getProviderPayments(providerId);
      final filteredPayments = payments.where((p) {
        if (p.status != PaymentStatus.completed) return false;
        if (p.paymentDate == null) return false;
        if (startDate != null && p.paymentDate!.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && p.paymentDate!.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();

      // تجميع حسب الشهر
      final earningsByMonth = <String, double>{};
      for (final payment in filteredPayments) {
        final monthKey =
            '${payment.paymentDate!.year}-${payment.paymentDate!.month.toString().padLeft(2, '0')}';
        earningsByMonth[monthKey] =
            (earningsByMonth[monthKey] ?? 0) + payment.amount;
      }
      return earningsByMonth;
    } catch (e) {
      return {};
    }
  }

  /// الحصول على أرباح حسب الكورس
  Future<Map<String, double>> getEarningsByCourse(String providerId) async {
    try {
      final payments = await getProviderPayments(providerId);
      final earningsByCourse = <String, double>{};
      for (final payment in payments) {
        if (payment.status == PaymentStatus.completed) {
          earningsByCourse[payment.courseId] =
              (earningsByCourse[payment.courseId] ?? 0) + payment.amount;
        }
      }
      return earningsByCourse;
    } catch (e) {
      return {};
    }
  }

  /// الحصول على عدد المدفوعات
  Future<int> getPaymentsCount(String providerId) async {
    try {
      return await _supabaseService.count(
        SupabaseConfig.paymentsTable,
        filters: {
          'provider_id': providerId,
          'status': 'completed',
        },
      );
    } catch (e) {
      return 0;
    }
  }
}
