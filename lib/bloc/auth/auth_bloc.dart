import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/main_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final MainRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthForgotPassword>(_onForgotPassword);
    on<AuthResetPassword>(_onResetPassword);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final isLoggedIn = await repository.isLoggedIn();
      if (isLoggedIn) {
        final user = await repository.getUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const AuthError(
            message: 'يرجى إدخال البريد الإلكتروني وكلمة المرور'));
        return;
      }

      if (!_isValidEmail(event.email)) {
        emit(const AuthError(message: 'يرجى إدخال بريد إلكتروني صحيح'));
        return;
      }

      if (event.password.length < 6) {
        emit(const AuthError(
            message: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'));
        return;
      }

      final result =
          await repository.loginWithResult(event.email, event.password);

      if (result['success'] == true) {
        final user = await repository.getUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthError(message: 'حدث خطأ في جلب بيانات المستخدم'));
        }
      } else {
        emit(AuthError(
            message: result['message'] as String? ??
                'البريد الإلكتروني أو كلمة المرور غير صحيحة'));
      }
    } catch (e) {
      emit(const AuthError(message: 'حدث خطأ غير متوقع في تسجيل الدخول'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      if (event.name.isEmpty ||
          event.email.isEmpty ||
          event.password.isEmpty ||
          event.phone.isEmpty) {
        emit(const AuthError(message: 'يرجى ملء جميع الحقول المطلوبة'));
        return;
      }

      if (!_isValidEmail(event.email)) {
        emit(const AuthError(message: 'يرجى إدخال بريد إلكتروني صحيح'));
        return;
      }

      if (event.password.length < 6) {
        emit(const AuthError(
            message: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'));
        return;
      }

      if (!_isValidPhone(event.phone)) {
        emit(const AuthError(
            message: 'يرجى إدخال رقم هاتف صحيح (+966xxxxxxxxx)'));
        return;
      }

      final result = await repository.registerWithResult(
        event.name,
        event.email,
        event.password,
        event.phone,
        userType: event.userType,
      );

      if (result['success'] == true) {
        // بعد التسجيل، نحاول تسجيل الدخول تلقائياً
        final loginResult =
            await repository.loginWithResult(event.email, event.password);
        if (loginResult['success'] == true) {
          final user = await repository.getUser();
          if (user != null) {
            emit(AuthAuthenticated(user: user));
          } else {
            // الحساب تم إنشاؤه لكن يحتاج تأكيد البريد
            emit(AuthRegistrationSuccess(
                message: 'تم إنشاء الحساب بنجاح. يرجى تأكيد بريدك الإلكتروني'));
          }
        } else {
          // تم إنشاء الحساب لكن يحتاج تأكيد البريد الإلكتروني
          emit(AuthRegistrationSuccess(
              message: 'تم إنشاء الحساب بنجاح. يرجى تأكيد بريدك الإلكتروني'));
        }
      } else {
        emit(AuthError(
            message: result['message'] as String? ?? 'فشل في إنشاء الحساب'));
      }
    } catch (e) {
      emit(const AuthError(message: 'حدث خطأ غير متوقع في إنشاء الحساب'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await repository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(const AuthError(message: 'حدث خطأ في تسجيل الخروج'));
    }
  }

  Future<void> _onForgotPassword(
    AuthForgotPassword event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      if (!_isValidEmail(event.email)) {
        emit(const AuthError(message: 'يرجى إدخال بريد إلكتروني صحيح'));
        return;
      }

      final result = await repository.sendPasswordResetEmail(event.email);

      if (result['success'] == true) {
        emit(AuthPasswordResetSent(email: event.email));
      } else {
        emit(AuthError(
            message: result['message'] as String? ??
                'حدث خطأ في إرسال رابط إعادة التعيين'));
      }
    } catch (e) {
      emit(const AuthError(
          message: 'حدث خطأ في إرسال رابط إعادة تعيين كلمة المرور'));
    }
  }

  Future<void> _onResetPassword(
    AuthResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      if (event.newPassword.length < 6) {
        emit(const AuthError(
            message: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'));
        return;
      }

      final result = await repository.updatePassword(event.newPassword);

      if (result['success'] == true) {
        emit(AuthPasswordResetSuccess());
      } else {
        emit(AuthError(
            message: result['message'] as String? ??
                'حدث خطأ في إعادة تعيين كلمة المرور'));
      }
    } catch (e) {
      emit(const AuthError(message: 'حدث خطأ في إعادة تعيين كلمة المرور'));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+966[0-9]{9}$').hasMatch(phone);
  }
}
