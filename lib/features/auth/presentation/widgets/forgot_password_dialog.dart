import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/auth/auth_bloc.dart';
import '../../../../bloc/auth/auth_event.dart';
import '../../../../bloc/auth/auth_state.dart';
import '../../data/validators/auth_validators.dart';
import 'auth_form_fields.dart';

/// حوار استعادة كلمة المرور
class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSend(BuildContext dialogContext) {
    if (_emailController.text.isNotEmpty) {
      final sanitizedEmail = EmailValidator.sanitize(_emailController.text);
      dialogContext
          .read<AuthBloc>()
          .add(AuthForgotPassword(email: sanitizedEmail));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthPasswordResetSent) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('تم إرسال رابط إعادة التعيين إلى ${state.email}'),
            backgroundColor: AuthColors.success,
            duration: const Duration(seconds: 4),
          ));
        } else if (state is AuthError) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AuthColors.error,
          ));
        }
      },
      builder: (ctx, state) {
        final isLoading = state is AuthLoading;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('استعادة كلمة المرور', textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, color: AuthColors.textMuted),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  hintText: 'example@wasla.com',
                  filled: true,
                  fillColor: AuthColors.inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.mail_outline_rounded,
                      color: AuthColors.textMuted.withOpacity(0.5)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'يرجى إدخال البريد الإلكتروني';
                  if (!EmailValidator.isValid(v))
                    return 'بريد إلكتروني غير صحيح';
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () => _handleSend(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AuthColors.primaryBg,
                foregroundColor: AuthColors.accentYellow,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AuthColors.accentYellow),
                      ),
                    )
                  : const Text('إرسال'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.start,
        );
      },
    );
  }
}

/// عرض حوار استعادة كلمة المرور
void showForgotPasswordDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: context.read<AuthBloc>(),
      child: const ForgotPasswordDialog(),
    ),
  );
}
