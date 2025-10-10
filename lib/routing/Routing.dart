import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/Auth.dart';
import '../screens/MainScreen.dart';
import '../repository/Repository.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // شاشة البداية
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // شاشات المصادقة
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // الشاشة الرئيسية مع علامات التبويب
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'] ?? '0';
          final tabIndex = int.tryParse(tab) ?? 0;
          return MainScreen(initialTabIndex: tabIndex);
        },
      ),

      // صفحة غير موجودة
      GoRoute(
        path: '/404',
        name: '404',
        builder: (context, state) => const NotFoundScreen(),
      ),
    ],

    // معالج الأخطاء
    errorBuilder: (context, state) => const NotFoundScreen(),

    // إعادة توجيه
    redirect: (context, state) async {
      // التحقق من حالة المصادقة
      final repository = Repository();
      final isLoggedIn = await repository.isLoggedIn();

      // إذا لم يكن المستخدم مسجلاً دخوله وحاول الوصول إلى الشاشة الرئيسية
      if (!isLoggedIn &&
          state.uri.toString() != '/auth' &&
          state.uri.toString() != '/splash') {
        return '/auth';
      }

      // إذا كان المستخدم مسجلاً دخوله وحاول الوصول إلى شاشة المصادقة
      if (isLoggedIn && state.uri.toString() == '/auth') {
        return '/main';
      }

      return null;
    },
  );
}

// شاشات إضافية مؤقتة
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صفحة غير موجودة')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'الصفحة غير موجودة',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// مساعدات التنقل
class NavigationHelper {
  static void goToMain(BuildContext context, {int tabIndex = 0}) {
    context.go('/main?tab=$tabIndex');
  }

  static void goToAuth(BuildContext context) {
    context.go('/auth');
  }

  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/main');
    }
  }
}

// معلومات المسار
class RouteInfo {
  final String path;
  final String name;
  final String title;
  final IconData icon;

  const RouteInfo({
    required this.path,
    required this.name,
    required this.title,
    required this.icon,
  });
}

// مسارات التطبيق
class AppRoutes {
  static const List<RouteInfo> mainRoutes = [
    RouteInfo(
      path: '/main/dashboard',
      name: 'dashboard',
      title: 'لوحة التحكم',
      icon: Icons.dashboard,
    ),
    RouteInfo(
      path: '/main/courses',
      name: 'courses',
      title: 'الدورات',
      icon: Icons.school,
    ),
    RouteInfo(
      path: '/main/students',
      name: 'students',
      title: 'الطلاب',
      icon: Icons.people,
    ),
    RouteInfo(
      path: '/main/certificates',
      name: 'certificates',
      title: 'الشهادات',
      icon: Icons.card_membership,
    ),

    RouteInfo(
      path: '/main/settings',
      name: 'settings',
      title: 'الإعدادات',
      icon: Icons.settings,
    ),
  ];

  static RouteInfo? getRouteInfo(String path) {
    try {
      return mainRoutes.firstWhere((route) => route.path == path);
    } catch (e) {
      return null;
    }
  }

  static String getRouteTitle(String path) {
    final routeInfo = getRouteInfo(path);
    return routeInfo?.title ?? 'غير معروف';
  }
}
