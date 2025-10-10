import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// مساعد التصميم المتجاوب
class ResponsiveHelper {
  /// التحقق من نوع الجهاز
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConfig.mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConfig.mobileBreakpoint &&
        width < AppConfig.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConfig.tabletBreakpoint;
  }

  /// الحصول على عدد الأعمدة المناسب للشبكة
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  /// الحصول على عدد الأعمدة للبطاقات
  static int getCardColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 4;
  }

  /// الحصول على المسافة المناسبة
  static double getPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 20.0;
    return 24.0;
  }

  /// الحصول على حجم الخط المناسب
  static double getFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize * 0.9;
    if (isTablet(context)) return baseFontSize;
    return baseFontSize * 1.1;
  }

  /// الحصول على حجم الأيقونة المناسب
  static double getIconSize(BuildContext context, double baseIconSize) {
    if (isMobile(context)) return baseIconSize * 0.9;
    if (isTablet(context)) return baseIconSize;
    return baseIconSize * 1.1;
  }

  /// الحصول على عرض الحاوية المناسب
  static double getContainerWidth(BuildContext context, double maxWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > maxWidth) return maxWidth;
    return screenWidth * 0.9;
  }

  /// الحصول على ارتفاع الحاوية المناسب
  static double getContainerHeight(BuildContext context, double baseHeight) {
    if (isMobile(context)) return baseHeight * 0.8;
    if (isTablet(context)) return baseHeight * 0.9;
    return baseHeight;
  }

  /// تحديد ما إذا كان يجب إظهار الشريط الجانبي
  static bool shouldShowSidebar(BuildContext context) {
    return !isMobile(context);
  }

  /// تحديد ما إذا كان يجب إظهار الشريط السفلي
  static bool shouldShowBottomNavigation(BuildContext context) {
    return isMobile(context);
  }

  /// الحصول على نوع التخطيط المناسب
  static LayoutType getLayoutType(BuildContext context) {
    if (isMobile(context)) return LayoutType.mobile;
    if (isTablet(context)) return LayoutType.tablet;
    return LayoutType.desktop;
  }

  /// الحصول على المسافة بين العناصر
  static double getSpacing(BuildContext context) {
    if (isMobile(context)) return 8.0;
    if (isTablet(context)) return 12.0;
    return 16.0;
  }

  /// الحصول على نصف قطر الحدود المناسب
  static double getBorderRadius(BuildContext context) {
    if (isMobile(context)) return 8.0;
    if (isTablet(context)) return 10.0;
    return 12.0;
  }
}

/// أنواع التخطيط
enum LayoutType {
  mobile,
  tablet,
  desktop,
}

/// ويدجت مساعد للتصميم المتجاوب
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, LayoutType layoutType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final layoutType = ResponsiveHelper.getLayoutType(context);
    return builder(context, layoutType);
  }
}

/// ويدجت للتخطيط المتجاوب
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, layoutType) {
        switch (layoutType) {
          case LayoutType.mobile:
            return mobile;
          case LayoutType.tablet:
            return tablet ?? mobile;
          case LayoutType.desktop:
            return desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}
