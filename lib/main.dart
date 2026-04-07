import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/Theme.dart';
import 'repository/main_repository.dart';
import 'bloc/bloc.dart';
import 'screens/Auth.dart';
import 'screens/MainScreen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Supabase
  await SupabaseService().initialize();

  runApp(const WaslaApp());
}

class WaslaApp extends StatelessWidget {
  const WaslaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MainRepository>(
          create: (context) => MainRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              repository: context.read<MainRepository>(),
            )..add(AuthCheckStatus()),
          ),
          BlocProvider<NavigationBloc>(
            create: (context) => NavigationBloc(),
          ),
          BlocProvider<CourseBloc>(
            create: (context) => CourseBloc(
              repository: context.read<MainRepository>(),
            ),
          ),
          // Removed StudentBloc provider
          BlocProvider<CertificateBloc>(
            create: (context) => CertificateBloc(
              repository: context.read<MainRepository>(),
            ),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              repository: context.read<MainRepository>(),
            ),
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            // تحديد الثيم بناءً على الإعدادات
            ThemeData theme = AppTheme.lightTheme;
            if (settingsState is SettingsLoaded) {
              theme = settingsState.settings.theme == 'dark'
                  ? AppTheme.darkTheme
                  : AppTheme.lightTheme;
            }

            return MaterialApp(
              title: 'وصلة - منصة مقدمي الخدمات التعليمية',
              theme: theme.copyWith(
                textTheme: GoogleFonts.cairoTextTheme(theme.textTheme),
              ),
              debugShowCheckedModeBanner: false,
              locale: const Locale('ar', 'SA'),
              supportedLocales: const [
                Locale('ar', 'SA'),
                Locale('en', 'US'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                );
              },
              home: const SplashScreen(),
              routes: {
                '/auth': (context) => const AuthScreen(),
                '/main': (context) => const MainScreen(),
              },
            );
          },
        ),
      ),
    );
  }
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
          Navigator.pushReplacementNamed(context, '/main');
        } else if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/auth');
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
