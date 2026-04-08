import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'data/repositories/main_repository.dart';
import 'data/services/supabase_service.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/certificate/certificate_bloc.dart';
import 'presentation/blocs/course/course_bloc.dart';
import 'presentation/blocs/navigation/navigation_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/blocs/settings/settings_state.dart';

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
