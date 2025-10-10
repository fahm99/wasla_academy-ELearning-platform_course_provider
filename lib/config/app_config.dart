/// إعدادات التطبيق
class AppConfig {
  static const String appName = 'وصلة - منصة مقدمي الخدمات التعليمية';
  static const String appVersion = '1.0.0';

  // مسارات التطبيق
  static const String splashRoute = '/';
  static const String authRoute = '/auth';
  static const String mainRoute = '/main';

  // أوقات التأخير
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // أحجام الشاشات
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  // إعدادات التنقل
  static const int defaultTabIndex = 0;
  static const bool enableBackNavigation = true;
}
