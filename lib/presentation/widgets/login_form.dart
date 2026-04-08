import 'package:course_provider/presentation/blocs/auth/auth_bloc.dart';
import 'package:course_provider/presentation/blocs/auth/auth_event.dart';
import 'package:course_provider/presentation/blocs/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/app_router.dart' show NavigationHelper;
import '../../../../data/validators/auth_validators.dart';
import '../../../../presentation/widgets/auth_form_fields.dart';

/// نموذج تسجيل الدخول
class LoginForm extends StatefulWidget {
  final VoidCallback onForgotPassword;

  const LoginForm({super.key, required this.onForgotPassword});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final sanitizedEmail = EmailValidator.sanitize(_emailController.text);
      context.read<AuthBloc>().add(AuthLoginRequested(
            email: sanitizedEmail,
            password: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AuthColors.error,
          ));
        } else if (state is AuthAuthenticated) {
          NavigationHelper.goToMain(context);
        } else if (state is AuthPasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('تم إرسال رابط إعادة التعيين إلى ${state.email}'),
            backgroundColor: AuthColors.success,
          ));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                hint: 'example@wasla.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  if (!EmailValidator.isValid(v)) {
                    return 'بريد إلكتروني غير صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                toggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  if (v.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v),
                          activeColor: AuthColors.primaryBg,
                          activeTrackColor:
                              AuthColors.primaryBg.withOpacity(0.3),
                        ),
                      ),
                      const Text('تذكرني',
                          style: TextStyle(
                              fontSize: 13, color: AuthColors.textMuted)),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onForgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: AuthColors.primaryBg,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('نسيت كلمة المرور؟',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AuthSubmitButton(
                label: 'دخول للمنصة',
                icon: Icons.arrow_back_rounded,
                isLoading: isLoading,
                onPressed: _handleLogin,
              ),
            ],
          ),
        );
      },
    );
  }
}
