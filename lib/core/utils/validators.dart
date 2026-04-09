/// مجموعة من المتحققات للتحقق من صحة البيانات
class Validators {
  /// التحقق من البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }

    return null;
  }

  /// التحقق من كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    return null;
  }

  /// التحقق من الاسم
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم مطلوب';
    }

    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    return null;
  }

  /// التحقق من رقم الهاتف
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    final phoneRegex = RegExp(r'^[0-9+\-\s()]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'يرجى إدخال رقم هاتف صحيح';
    }

    if (value.trim().length < 10) {
      return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
    }

    return null;
  }

  /// التحقق من عنوان الكورس
  static String? validateCourseTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'عنوان الكورس مطلوب';
    }

    if (value.trim().length < 3) {
      return 'عنوان الكورس يجب أن يكون 3 أحرف على الأقل';
    }

    if (value.trim().length > 100) {
      return 'عنوان الكورس يجب أن يكون أقل من 100 حرف';
    }

    return null;
  }

  /// التحقق من وصف الكورس
  static String? validateCourseDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'وصف الكورس مطلوب';
    }

    if (value.trim().length < 10) {
      return 'وصف الكورس يجب أن يكون 10 أحرف على الأقل';
    }

    if (value.trim().length > 1000) {
      return 'وصف الكورس يجب أن يكون أقل من 1000 حرف';
    }

    return null;
  }

  /// التحقق من السعر
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'السعر مطلوب';
    }

    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'يرجى إدخال سعر صحيح';
    }

    if (price < 0) {
      return 'السعر لا يمكن أن يكون سالباً';
    }

    if (price > 10000) {
      return 'السعر لا يمكن أن يتجاوز 10,000 ريال';
    }

    return null;
  }

  /// التحقق من المدة
  static String? validateDuration(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final duration = int.tryParse(value.trim());
      if (duration == null) {
        return 'يرجى إدخال مدة صحيحة';
      }

      if (duration <= 0) {
        return 'المدة يجب أن تكون أكبر من صفر';
      }

      if (duration > 1000) {
        return 'المدة لا يمكن أن تتجاوز 1000 ساعة';
      }
    }

    return null;
  }

  /// التحقق من النص العام
  static String? validateText(
    String? value, {
    required String fieldName,
    int minLength = 1,
    int maxLength = 255,
    bool required = true,
  }) {
    if (required && (value == null || value.trim().isEmpty)) {
      return '$fieldName مطلوب';
    }

    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length < minLength) {
        return '$fieldName يجب أن يكون $minLength أحرف على الأقل';
      }

      if (value.trim().length > maxLength) {
        return '$fieldName يجب أن يكون أقل من $maxLength حرف';
      }
    }

    return null;
  }

  /// التحقق من الرقم
  static String? validateNumber(
    String? value, {
    required String fieldName,
    double? min,
    double? max,
    bool required = true,
  }) {
    if (required && (value == null || value.trim().isEmpty)) {
      return '$fieldName مطلوب';
    }

    if (value != null && value.trim().isNotEmpty) {
      final number = double.tryParse(value.trim());
      if (number == null) {
        return 'يرجى إدخال $fieldName صحيح';
      }

      if (min != null && number < min) {
        return '$fieldName لا يمكن أن يكون أقل من $min';
      }

      if (max != null && number > max) {
        return '$fieldName لا يمكن أن يتجاوز $max';
      }
    }

    return null;
  }

  /// التحقق من الرابط
  static String? validateUrl(String? value, {bool required = false}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'الرابط مطلوب';
    }

    if (value != null && value.trim().isNotEmpty) {
      final urlRegex = RegExp(
          r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');

      if (!urlRegex.hasMatch(value.trim())) {
        return 'يرجى إدخال رابط صحيح';
      }
    }

    return null;
  }
}
