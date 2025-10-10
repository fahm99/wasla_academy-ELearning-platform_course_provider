import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../utils/navigation_helper.dart';

/// مساعد حالة التطبيق
class AppStateHelper {
  /// التحقق من حالة المصادقة والتنقل المناسب
  static void handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      NavigationHelper.goToMain(context);
    } else if (state is AuthUnauthenticated) {
      NavigationHelper.goToAuth(context);
    } else if (state is AuthError) {
      NavigationHelper.showErrorMessage(context, state.message);
    }
  }

  /// معالجة أخطاء التطبيق العامة
  static void handleError(BuildContext context, String error) {
    NavigationHelper.showErrorMessage(context, error);
  }

  /// معالجة رسائل النجاح
  static void handleSuccess(BuildContext context, String message) {
    NavigationHelper.showSuccessMessage(context, message);
  }

  /// التحقق من اتصال الإنترنت (يمكن تطويره لاحقاً)
  static Future<bool> checkInternetConnection() async {
    // يمكن إضافة منطق التحقق من الاتصال هنا
    return true;
  }

  /// تحديث حالة التطبيق عند تغيير الإعدادات
  static void updateAppSettings(BuildContext context) {
    context.read<SettingsBloc>().add(SettingsLoadRequested());
  }

  /// تحديث البيانات عند العودة للتطبيق
  static void refreshAppData(BuildContext context) {
    context.read<CourseBloc>().add(CourseLoadRequested());
    context.read<StudentBloc>().add(StudentLoadRequested());
    context.read<CertificateBloc>().add(CertificateLoadRequested());
  }
}
