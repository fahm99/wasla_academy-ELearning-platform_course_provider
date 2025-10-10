import 'package:intl/intl.dart';

/// مساعد التنسيق
class FormatHelper {
  /// تنسيق التاريخ
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ar').format(date);
  }

  /// تنسيق التاريخ والوقت
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm', 'ar').format(dateTime);
  }

  /// تنسيق الوقت فقط
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm', 'ar').format(time);
  }

  /// تنسيق المبلغ المالي
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'ar');
    return '${formatter.format(amount)} ر.س';
  }

  /// تنسيق الرقم
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,##0', 'ar');
    return formatter.format(number);
  }

  /// تنسيق النسبة المئوية
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// تنسيق حجم الملف
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes بايت';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} جيجابايت';
  }

  /// تنسيق المدة الزمنية
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hoursس $minutesد';
    } else {
      return '$minutesد';
    }
  }

  /// تنسيق النص المقطوع
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// تنسيق رقم الهاتف
  static String formatPhoneNumber(String phone) {
    // إزالة جميع الأحرف غير الرقمية
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length == 10) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }

    return phone; // إرجاع الرقم كما هو إذا لم يكن بالتنسيق المتوقع
  }

  /// تحويل النص إلى أحرف كبيرة للكلمة الأولى
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// تحويل النص إلى أحرف كبيرة لكل كلمة
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalizeFirst(word)).join(' ');
  }
}
