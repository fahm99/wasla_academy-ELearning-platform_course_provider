import 'package:course_provider/features/auth/presentation/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/Theme.dart';
import 'repository/main_repository.dart';
import 'bloc/bloc.dart';
import 'screens/MainScreen.dart';
import 'services/supabase_service.dart';
import 'routing/Routing.dart';

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

            return MaterialApp.router(
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
              routerConfig: AppRouter.router,
              builder: (context, child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
