import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/auth/auth_bloc.dart';
import '../../../../bloc/auth/auth_event.dart';
import '../../../../bloc/auth/auth_state.dart';
import '../../../../routing/Routing.dart' show NavigationHelper;
import '../../data/validators/auth_validators.dart';
import 'auth_form_fields.dart';

/// نموذج إنشاء حساب جديد
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  double _passwordStrength = 0.0;
  List<String> _passwordErrors = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    final result = PasswordValidator.validate(value);
    setState(() {
      _passwordStrength = result.strength;
      _passwordErrors = result.errors;
    });
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      // تنظيف المدخلات
      final sanitizedName = NameValidator.sanitize(_nameController.text);
      final sanitizedEmail = EmailValidator.sanitize(_emailController.text);
      final formattedPhone = PhoneValidator.format(_phoneController.text);

      context.read<AuthBloc>().add(AuthRegisterRequested(
            name: sanitizedName,
            email: sanitizedEmail,
            password: _passwordController.text,
            phone: formattedPhone,
            userType: 'provider',
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
        } else if (state is AuthRegistrationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AuthColors.success,
            duration: const Duration(seconds: 4),
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
                controller: _nameController,
                label: 'الاسم الكامل',
                hint: 'أدخل اسمك الكامل',
                icon: Icons.person_outline_rounded,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'يرجى إدخال الاسم الكامل';
                  }
                  if (!NameValidator.isValid(v)) {
                    return 'الاسم يجب أن يكون 3 أحرف على الأقل (أحرف فقط)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              AuthTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                hint: '+967xxxxxxxxx',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  if (!PhoneValidator.isValid(v)) {
                    return 'رقم هاتف غير صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                toggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onChanged: _onPasswordChanged,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  final result = PasswordValidator.validate(v);
                  if (!result.isValid) {
                    return 'كلمة المرور لا تستوفي الشروط';
                  }
                  return null;
                },
                suffixWidget: _passwordStrength > 0
                    ? Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          PasswordValidator.getStrengthText(_passwordStrength),
                          style: TextStyle(
                            fontSize: 10,
                            color: PasswordValidator.getStrengthColor(
                                _passwordStrength),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              // مؤشر قوة كلمة المرور
              if (_passwordController.text.isNotEmpty)
                PasswordStrengthIndicator(
                  strength: _passwordStrength,
                  errors: _passwordErrors,
                ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscureConfirmPassword,
                toggleObscure: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'يرجى تأكيد كلمة المرور';
                  }
                  if (v != _passwordController.text) {
                    return 'كلمة المرور غير متطابقة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                    activeColor: AuthColors.primaryBg,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              fontSize: 13, color: AuthColors.textMuted),
                          children: [
                            TextSpan(text: 'أوافق على '),
                            TextSpan(
                              text: 'الشروط والأحكام',
                              style: TextStyle(
                                color: AuthColors.primaryBg,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: ' و '),
                            TextSpan(
                              text: 'سياسة الخصوصية',
                              style: TextStyle(
                                color: AuthColors.primaryBg,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AuthSubmitButton(
                label: 'إنشاء الحساب',
                icon: Icons.person_add_alt_1_rounded,
                isLoading: isLoading,
                onPressed:
                    (!_acceptTerms || isLoading) ? null : _handleRegister,
              ),
            ],
          ),
        );
      },
    );
  }
}
