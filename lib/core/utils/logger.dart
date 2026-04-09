import 'dart:developer' as developer;

/// خدمة التسجيل المحسنة للتطبيق
class Logger {
  static const String _tag = 'Wasla';

  /// تسجيل معلومات عامة
  static void info(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800,
    );
  }

  /// تسجيل تحذيرات
  static void warning(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900,
    );
  }

  /// تسجيل أخطاء
  static void error(String message,
      [Object? error, StackTrace? stackTrace, String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// تسجيل تصحيح الأخطاء
  static void debug(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 700,
    );
  }

  /// تسجيل نجاح العمليات
  static void success(String message, [String? tag]) {
    developer.log(
      '✅ $message',
      name: tag ?? _tag,
      level: 800,
    );
  }
}
