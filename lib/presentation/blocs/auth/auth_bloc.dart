import 'package:course_provider/data/validators/auth_validators.dart';
import 'package:course_provider/data/repositories/main_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

      if (!EmailValidator.isValid(event.email)) {
        emit(const AuthError(message: 'يرجى إدخال بريد إلكتروني صحيح'));
        return;
      }

      if (event.password.length < 6) {
        emit(const AuthError(
            message: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'));
        return;
      }

      // تنظيف البريد الإلكتروني
      final sanitizedEmail = EmailValidator.sanitize(event.email);

      final result =
          await repository.loginWithResult(sanitizedEmail, event.password);

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

      // التحقق من الحقول الفارغة
      if (event.name.isEmpty ||
          event.email.isEmpty ||
          event.password.isEmpty ||
          event.phone.isEmpty) {
        emit(const AuthError(message: 'يرجى ملء جميع الحقول المطلوبة'));
        return;
      }

      // التحقق من الاسم
      if (!NameValidator.isValid(event.name)) {
        emit(const AuthError(
            message: 'الاسم يجب أن يكون 3 أحرف على الأقل (أحرف فقط)'));
        return;
      }

      // التحقق من البريد الإلكتروني
      if (!EmailValidator.isValid(event.email)) {
        emit(const AuthError(message: 'يرجى إدخال بريد إلكتروني صحيح'));
        return;
      }

      // التحقق من قوة كلمة المرور
      final passwordResult = PasswordValidator.validate(event.password);
      if (!passwordResult.isValid) {
        emit(AuthError(message: passwordResult.errors.first));
        return;
      }

      // التحقق من رقم الهاتف
      if (!PhoneValidator.isValid(event.phone)) {
        emit(const AuthError(message: 'يرجى إدخال رقم هاتف صحيح'));
        return;
      }

      // تنظيف المدخلات
      final sanitizedName = NameValidator.sanitize(event.name);
      final sanitizedEmail = EmailValidator.sanitize(event.email);
      final formattedPhone = PhoneValidator.format(event.phone);

      final result = await repository.registerWithResult(
        sanitizedName,
        sanitizedEmail,
        event.password,
        formattedPhone,
        userType: event.userType,
      );

      if (result['success'] == true) {
        final loginResult =
            await repository.loginWithResult(sanitizedEmail, event.password);
        if (loginResult['success'] == true) {
          final user = await repository.getUser();
          if (user != null) {
            emit(AuthAuthenticated(user: user));
          } else {
            emit(const AuthRegistrationSuccess(
                message: 'تم إنشاء الحساب بنجاح. يرجى تأكيد بريدك الإلكتروني'));
          }
        } else {
          emit(const AuthRegistrationSuccess(
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

      if (!EmailValidator.isValid(event.email)) {
        emit(const AuthError(message: 'يرجى إدخال بريد إلكتروني صحيح'));
        return;
      }

      final sanitizedEmail = EmailValidator.sanitize(event.email);
      final result = await repository.sendPasswordResetEmail(sanitizedEmail);

      if (result['success'] == true) {
        emit(AuthPasswordResetSent(email: sanitizedEmail));
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

      // التحقق من قوة كلمة المرور الجديدة
      final passwordResult = PasswordValidator.validate(event.newPassword);
      if (!passwordResult.isValid) {
        emit(AuthError(message: passwordResult.errors.first));
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
}
