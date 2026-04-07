import 'package:flutter/material.dart';

/// نتائج التحقق من كلمة المرور
class PasswordValidationResult {
  final bool isValid;
  final List<String> errors;
  final double strength;

  const PasswordValidationResult({
    required this.isValid,
    required this.errors,
    required this.strength,
  });
}

/// مدقق كلمة المرور مع قواعد أمان قوية
class PasswordValidator {
  static const int minLength = 8;

  /// التحقق من قوة كلمة المرور
  static PasswordValidationResult validate(String password) {
    final errors = <String>[];
    double strength = 0.0;

    // التحقق من الطول
    if (password.length < minLength) {
      errors.add('يجب أن تكون $minLength أحرف على الأقل');
    } else {
      strength += 0.2;
    }

    // التحقق من الأحرف الكبيرة
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    if (!hasUppercase) {
      errors.add('يجب أن تحتوي على حرف كبير واحد على الأقل (A-Z)');
    } else {
      strength += 0.2;
    }

    // التحقق من الأحرف الصغيرة
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    if (!hasLowercase) {
      errors.add('يجب أن تحتوي على حرف صغير واحد على الأقل (a-z)');
    } else {
      strength += 0.2;
    }

    // التحقق من الأرقام
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    if (!hasNumber) {
      errors.add('يجب أن تحتوي على رقم واحد على الأقل (0-9)');
    } else {
      strength += 0.2;
    }

    // التحقق من الرموز الخاصة
    bool hasSpecial =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\+=\[\]\\]'));
    if (!hasSpecial) {
      errors.add('يجب أن تحتوي على رمز خاص واحد على الأقل');
    } else {
      strength += 0.2;
    }

    return PasswordValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      strength: strength,
    );
  }

  /// الحصول على لون قوة كلمة المرور
  static Color getStrengthColor(double strength) {
    if (strength < 0.4) return Colors.red;
    if (strength < 0.7) return Colors.orange;
    if (strength < 0.9) return Colors.lightGreen;
    return Colors.green;
  }

  /// الحصول على نص قوة كلمة المرور
  static String getStrengthText(double strength) {
    if (strength < 0.4) return 'ضعيفة جداً';
    if (strength < 0.7) return 'ضعيفة';
    if (strength < 0.9) return 'متوسطة';
    return 'قوية';
  }
}

/// مدقق البريد الإلكتروني
class EmailValidator {
  /// التحقق من صحة البريد الإلكتروني
  static bool isValid(String email) {
    if (email.isEmpty) return false;
    final pattern = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return pattern.hasMatch(email.trim());
  }

  /// تنظيف البريد الإلكتروني
  static String sanitize(String email) {
    var sanitized = email.trim().toLowerCase();
    // إزالة أحرف خطرة
    sanitized = sanitized.replaceAll('<', '');
    sanitized = sanitized.replaceAll('>', '');
    sanitized = sanitized.replaceAll('"', '');
    sanitized = sanitized.replaceAll("'", '');
    sanitized = sanitized.replaceAll(';', '');
    sanitized = sanitized.replaceAll('\\', '');
    return sanitized;
  }
}

/// مدقق رقم الهاتف
class PhoneValidator {
  /// التحقق من صحة رقم الهاتف
  static bool isValid(String phone) {
    if (phone.isEmpty) return false;
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final yemenPattern = RegExp(r'^(\+967|967|0)?[0-9]{9}$');
    final saudiPattern = RegExp(r'^(\+966|966|0)?[0-9]{9}$');
    final uaePattern = RegExp(r'^(\+971|971|0)?[0-9]{9}$');
    return yemenPattern.hasMatch(cleanPhone) ||
        saudiPattern.hasMatch(cleanPhone) ||
        uaePattern.hasMatch(cleanPhone);
  }

  /// تنسيق رقم الهاتف
  static String format(String phone) {
    var cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanPhone.startsWith('+')) {
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '+967${cleanPhone.substring(1)}';
      } else {
        cleanPhone = '+967$cleanPhone';
      }
    }
    return cleanPhone;
  }
}

/// مدقق الاسم
class NameValidator {
  static const int minLength = 3;
  static const int maxLength = 100;

  /// التحقق من صحة الاسم
  static bool isValid(String name) {
    if (name.isEmpty) return false;
    final trimmed = name.trim();
    if (trimmed.length < minLength || trimmed.length > maxLength) return false;
    return RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$').hasMatch(trimmed);
  }

  /// تنظيف الاسم
  static String sanitize(String name) {
    var sanitized = name.trim();
    // إزالة أحرف خطرة
    sanitized = sanitized.replaceAll('<', '');
    sanitized = sanitized.replaceAll('>', '');
    sanitized = sanitized.replaceAll('"', '');
    sanitized = sanitized.replaceAll("'", '');
    sanitized = sanitized.replaceAll(';', '');
    sanitized = sanitized.replaceAll('\\', '');
    sanitized = sanitized.replaceAll('/', '');
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    return sanitized;
  }
}

/// أداة تنظيف المدخلات العامة
class InputSanitizer {
  /// تنظيف النص العام
  static String sanitize(String input) {
    var sanitized = input.trim();
    // إزالة أحرف خطرة
    sanitized = sanitized.replaceAll("'", '');
    sanitized = sanitized.replaceAll('"', '');
    sanitized = sanitized.replaceAll(';', '');
    sanitized = sanitized.replaceAll('\\', '');
    sanitized = sanitized.replaceAll('<', '');
    sanitized = sanitized.replaceAll('>', '');
    return sanitized;
  }

  /// تنظيف للعرض في HTML
  static String escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }
}
