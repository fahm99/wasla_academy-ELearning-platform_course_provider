import 'package:course_provider/presentation/screens/auth_screen.dart';
import 'package:course_provider/presentation/screens/main_screen.dart';
import 'package:flutter/material.dart';

/// مساعد التنقل المبسط
class NavigationHelper {
  /// التنقل إلى شاشة جديدة
  static Future<T?> navigateTo<T>(
    BuildContext context,
    Widget screen, {
    bool replace = false,
  }) {
    if (replace) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    } else {
      return Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  /// العودة للخلف
  static void goBack(BuildContext context, [dynamic result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }

  /// العودة إلى الشاشة الرئيسية
  static void goToMain(BuildContext context, {int tabIndex = 0}) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(initialTabIndex: tabIndex),
      ),
      (route) => false,
    );
  }

  /// الانتقال إلى شاشة المصادقة
  static void goToAuth(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
  }

  /// إظهار حوار تأكيد
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// إظهار رسالة نجاح
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// إظهار رسالة خطأ
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// معلومات التبويب
class TabInfo {
  final String title;
  final String breadcrumb;
  final IconData icon;

  const TabInfo({
    required this.title,
    required this.breadcrumb,
    required this.icon,
  });
}

/// معلومات التبويبات
class AppTabs {
  static const List<TabInfo> tabs = [
    TabInfo(
      title: 'لوحة التحكم',
      breadcrumb: 'الرئيسية',
      icon: Icons.dashboard,
    ),
    TabInfo(
      title: 'إدارة الدورات',
      breadcrumb: 'الرئيسية > الدورات',
      icon: Icons.school,
    ),
    TabInfo(
      title: 'إدارة الطلاب',
      breadcrumb: 'الرئيسية > الطلاب',
      icon: Icons.people,
    ),
    TabInfo(
      title: 'إدارة الشهادات',
      breadcrumb: 'الرئيسية > الشهادات',
      icon: Icons.card_membership,
    ),
    TabInfo(
      title: 'الإعدادات',
      breadcrumb: 'الرئيسية > الإعدادات',
      icon: Icons.settings,
    ),
  ];

  static TabInfo getTabInfo(int index) {
    if (index >= 0 && index < tabs.length) {
      return tabs[index];
    }
    return tabs[0]; // العودة للتبويب الأول كافتراضي
  }
}
