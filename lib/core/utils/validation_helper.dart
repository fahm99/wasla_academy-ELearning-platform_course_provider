/// مساعد التحقق من صحة البيانات
class ValidationHelper {
  /// التحقق من صحة البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }

    return null;
  }

  /// التحقق من صحة كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }

    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    return null;
  }

  /// التحقق من صحة الاسم
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الاسم';
    }

    if (value.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    return null;
  }

  /// التحقق من صحة رقم الهاتف
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
      return 'يرجى إدخال رقم هاتف صحيح (10 أرقام)';
    }

    return null;
  }

  /// التحقق من صحة النص المطلوب
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    return null;
  }

  /// التحقق من صحة الرقم
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال $fieldName';
    }

    if (double.tryParse(value) == null) {
      return 'يرجى إدخال رقم صحيح';
    }

    return null;
  }

  /// التحقق من صحة الرابط
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // اختياري
    }

    final urlRegex = RegExp(r'^https?:\/\/.+');
    if (!urlRegex.hasMatch(value)) {
      return 'يرجى إدخال رابط صحيح يبدأ بـ http:// أو https://';
    }

    return null;
  }
}
