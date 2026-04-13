import 'package:course_provider/data/services/supabase_service.dart';
import 'package:course_provider/data/models/payment_settings.dart';
import '../models/payment.dart';
import '../../core/config/supabase_config.dart';

/// خدمة إدارة المدفوعات
class PaymentService {
  final SupabaseService _supabaseService = SupabaseService();

  /// الحصول على مدفوعات مقدم الخدمة مع تفاصيل الطالب والكورس
  Future<List<Payment>> getProviderPayments(String providerId,
      {int? limit}) async {
    try {
      final data = await _supabaseService.client
          .from(SupabaseConfig.paymentsTable)
          .select('''
            *,
            users!payments_student_id_fkey(id, name, email),
            courses(id, title)
          ''')
          .eq('provider_id', providerId)
          .order('created_at', ascending: false)
          .limit(limit ?? 100);

      return data.map((e) {
        // إضافة اسم الطالب والكورس
        final payment = Payment.fromJson(e);
        final studentData = e['users'];
        final courseData = e['courses'];

        return Payment(
          id: payment.id,
          studentId: payment.studentId,
          courseId: payment.courseId,
          providerId: payment.providerId,
          amount: payment.amount,
          currency: payment.currency,
          paymentMethod: payment.paymentMethod,
          transactionId: payment.transactionId,
          transactionReference: payment.transactionReference,
          receiptImageUrl: payment.receiptImageUrl,
          studentName: studentData != null ? studentData['name'] : null,
          courseName: courseData != null ? courseData['title'] : null,
          status: payment.status,
          paymentDate: payment.paymentDate,
          verifiedBy: payment.verifiedBy,
          verifiedAt: payment.verifiedAt,
          rejectionReason: payment.rejectionReason,
          createdAt: payment.createdAt,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// تأكيد الدفع
  Future<bool> approvePayment(String paymentId, String verifiedBy) async {
    try {
      await _supabaseService.client.rpc('update_payment_status', params: {
        'p_payment_id': paymentId,
        'p_new_status': 'completed',
        'p_verified_by': verifiedBy,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// رفض الدفع
  Future<bool> rejectPayment(
    String paymentId,
    String verifiedBy,
    String rejectionReason,
  ) async {
    try {
      await _supabaseService.client.rpc('update_payment_status', params: {
        'p_payment_id': paymentId,
        'p_new_status': 'failed',
        'p_verified_by': verifiedBy,
        'p_rejection_reason': rejectionReason,
      });
      return true;
    } catch (e) {
      return false;
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

  // ============================================
  // إعدادات الدفع
  // ============================================

  /// الحصول على إعدادات الدفع للمقدم
  Future<PaymentSettings?> getPaymentSettings(String providerId) async {
    try {
      final data = await _supabaseService.client
          .from('provider_payment_settings')
          .select()
          .eq('provider_id', providerId)
          .maybeSingle();

      if (data == null) return null;
      return PaymentSettings.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// حفظ أو تحديث إعدادات الدفع
  Future<bool> savePaymentSettings(PaymentSettings settings) async {
    try {
      // التحقق من وجود إعدادات سابقة
      final existing = await getPaymentSettings(settings.providerId);

      if (existing != null) {
        // تحديث - لا نرسل id في التحديث
        final updateData = settings.toJson();
        updateData.remove('id');
        updateData.remove('created_at');

        await _supabaseService.client
            .from('provider_payment_settings')
            .update(updateData)
            .eq('provider_id', settings.providerId);
      } else {
        // إنشاء جديد - لا نرسل id لأن قاعدة البيانات ستولده تلقائيًا
        final insertData = settings.toJson();
        insertData.remove('id');

        await _supabaseService.client
            .from('provider_payment_settings')
            .insert(insertData);
      }
      return true;
    } catch (e) {
      print('خطأ في حفظ إعدادات الدفع: $e');
      rethrow;
    }
  }
}
