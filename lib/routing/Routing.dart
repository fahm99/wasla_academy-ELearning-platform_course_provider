import 'package:course_provider/features/auth/presentation/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../screens/MainScreen.dart';
import '../theme/Theme.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';

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
  );
}

// شاشة البداية (Splash Screen)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();

    // تحميل الإعدادات والتحقق من حالة المصادقة
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // تحميل الإعدادات
    context.read<SettingsBloc>().add(SettingsLoadRequested());

    // التحقق من حالة المصادقة
    context.read<AuthBloc>().add(AuthCheckStatus());

    // انتظار لمدة ثانيتين لعرض شاشة البداية
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/main');
        } else if (state is AuthUnauthenticated) {
          context.go('/auth');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(75),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school,
                            size: 80,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'وصلة',
                    style: AppTheme.splashTitle,
                  ),
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'منصة مقدمي الخدمات التعليمية',
                    style: AppTheme.splashSubtitle,
                  ),
                ),
                const SizedBox(height: 50),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.yellow),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
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
