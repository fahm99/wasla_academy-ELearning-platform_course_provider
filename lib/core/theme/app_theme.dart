import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الأساسية - مطابقة لتصميم HTML
  static const Color darkBlue = Color(0xFF0C1445); // Primary color from HTML
  static const Color secondary = Color(0xFF735C00); // Secondary color from HTML
  static const Color yellow = Color(0xFFFFD54F); // Yellow from HTML
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF757575);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);
  static const Color blue = Color(0xFF2196F3);

  // الثيم الفاتح
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    primarySwatch: MaterialColor(
      darkBlue.value,
      <int, Color>{
        50: darkBlue.withOpacity(0.1),
        100: darkBlue.withOpacity(0.2),
        200: darkBlue.withOpacity(0.3),
        300: darkBlue.withOpacity(0.4),
        400: darkBlue.withOpacity(0.5),
        500: darkBlue,
        600: darkBlue.withOpacity(0.7),
        700: darkBlue.withOpacity(0.8),
        800: darkBlue.withOpacity(0.9),
        900: darkBlue,
      },
    ),
    primaryColor: darkBlue,
    scaffoldBackgroundColor: white,
    colorScheme: const ColorScheme.light(
      primary: darkBlue,
      secondary: yellow,
      surface: white,
      error: red,
      onPrimary: white,
      onSecondary: darkBlue,
      onSurface: darkBlue,
      onError: white,
    ),

    // شريط التطبيق
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: darkBlue,
      elevation: 2,
      shadowColor: Colors.black12,
      titleTextStyle: TextStyle(
        color: darkBlue,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Cairo',
      ),
      iconTheme: IconThemeData(color: darkBlue),
    ),

    // البطاقات
    cardTheme: CardTheme(
      color: white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // الأزرار المرتفعة
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: yellow,
        foregroundColor: darkBlue,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    ),

    // الأزرار المحددة
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkBlue,
        side: const BorderSide(color: darkBlue, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    ),

    // الأزرار النصية
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Cairo',
        ),
      ),
    ),

    // حقول الإدخال
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: mediumGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: mediumGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: red, width: 2),
      ),
      labelStyle: const TextStyle(
        color: darkGray,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Cairo',
      ),
      hintStyle: const TextStyle(
        color: darkGray,
        fontSize: 14,
        fontFamily: 'Cairo',
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    ),

    // النصوص
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: darkGray,
        fontFamily: 'Cairo',
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: darkGray,
        fontFamily: 'Cairo',
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: darkGray,
        fontFamily: 'Cairo',
      ),
    ),

    // الأيقونات
    iconTheme: const IconThemeData(
      color: darkBlue,
      size: 24,
    ),

    // شريط التبويب السفلي
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: yellow,
      unselectedItemColor: darkGray,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Cairo',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: 'Cairo',
      ),
    ),

    // الدرج الجانبي
    drawerTheme: const DrawerThemeData(
      backgroundColor: darkBlue,
      scrimColor: Colors.black54,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          bottomLeft: Radius.circular(0),
        ),
      ),
    ),

    // النوافذ المنبثقة
    dialogTheme: DialogTheme(
      backgroundColor: white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        color: darkBlue,
        fontFamily: 'Cairo',
      ),
    ),

    // شريط التمرير
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(darkGray.withOpacity(0.5)),
      trackColor: WidgetStateProperty.all(lightGray),
      radius: const Radius.circular(4),
      thickness: WidgetStateProperty.all(6),
    ),

    // المؤشرات
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: yellow,
      linearTrackColor: mediumGray,
      circularTrackColor: mediumGray,
    ),

    // الشرائح
    sliderTheme: SliderThemeData(
      activeTrackColor: yellow,
      inactiveTrackColor: mediumGray,
      thumbColor: yellow,
      overlayColor: yellow.withOpacity(0.2),
      valueIndicatorColor: darkBlue,
      valueIndicatorTextStyle: const TextStyle(
        color: white,
        fontSize: 12,
        fontFamily: 'Cairo',
      ),
    ),

    // المفاتيح
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return white;
        }
        return mediumGray;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return darkBlue;
        }
        return darkGray;
      }),
    ),

    // مربعات الاختيار
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return darkBlue;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(white),
      side: const BorderSide(color: darkGray, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // أزرار الراديو
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return darkBlue;
        }
        return darkGray;
      }),
    ),
  );

  // الثيم الداكن
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    brightness: Brightness.dark,
    primarySwatch: MaterialColor(
      yellow.value,
      <int, Color>{
        50: yellow.withOpacity(0.1),
        100: yellow.withOpacity(0.2),
        200: yellow.withOpacity(0.3),
        300: yellow.withOpacity(0.4),
        400: yellow.withOpacity(0.5),
        500: yellow,
        600: yellow.withOpacity(0.7),
        700: yellow.withOpacity(0.8),
        800: yellow.withOpacity(0.9),
        900: yellow,
      },
    ),
    primaryColor: yellow,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: yellow,
      secondary: darkBlue,
      surface: Color(0xFF1E1E1E),
      error: red,
      onPrimary: darkBlue,
      onSecondary: white,
      onSurface: white,
      onError: white,
    ),
  );

  // أنماط مخصصة للبطاقات
  static BoxDecoration cardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // أنماط مخصصة للظلال
  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );

  static BoxShadow buttonShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );

  // التدرجات اللونية
  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBlue, Color(0xFF1A237E)],
  );

  static LinearGradient yellowGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [yellow, Color(0xFFE6C719)],
  );

  // أنماط النصوص المخصصة
  static const TextStyle splashTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: white,
    fontFamily: 'Cairo',
  );

  static const TextStyle splashSubtitle = TextStyle(
    fontSize: 18,
    color: yellow,
    fontFamily: 'Cairo',
  );

  static const TextStyle authTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: darkBlue,
    fontFamily: 'Cairo',
  );

  static const TextStyle authSubtitle = TextStyle(
    fontSize: 16,
    color: darkGray,
    fontFamily: 'Cairo',
  );

  static const TextStyle sidebarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: white,
    fontFamily: 'Cairo',
  );

  static const TextStyle menuItem = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(
        0xB3FFFFFF), // Replaced Colors.white70 with equivalent color value
    fontFamily: 'Cairo',
  );

  static const TextStyle menuItemActive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: yellow,
    fontFamily: 'Cairo',
  );

  // أنماط الحالات
  static TextStyle statusStyle(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'published':
      case 'approved':
      case 'active':
        color = green;
        break;
      case 'pending':
        color = blue;
        break;
      case 'draft':
        color = const Color(0xFFFF9800);
        break;
      case 'rejected':
      case 'inactive':
        color = red;
        break;
      default:
        color = darkGray;
    }

    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: color,
      fontFamily: 'Cairo',
    );
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
      case 'approved':
      case 'active':
        return green.withOpacity(0.1);
      case 'pending':
        return blue.withOpacity(0.1);
      case 'draft':
        return const Color(0xFFFF9800).withOpacity(0.1);
      case 'rejected':
      case 'inactive':
        return red.withOpacity(0.1);
      default:
        return darkGray.withOpacity(0.1);
    }
  }

  // الحركات والانتقالات
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;

  // المسافات والأحجام
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double borderRadius = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
}
