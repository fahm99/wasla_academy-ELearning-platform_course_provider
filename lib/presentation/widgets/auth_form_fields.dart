import 'package:flutter/material.dart';
import '../../data/validators/auth_validators.dart';

/// ألوان التصميم
class AuthColors {
  static const Color primaryBg = Color(0xFF0E1647);
  static const Color accentYellow = Color(0xFFFFDB23);
  static const Color surfaceLow = Color(0xFFF4F2FF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF46464F);
  static const Color inputBg = Color(0xFFF4F2FF);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
}

/// حقل إدخال مخصص
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? toggleObscure;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Widget? suffixWidget;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.toggleObscure,
    this.validator,
    this.onChanged,
    this.suffixWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AuthColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AuthColors.textMuted.withOpacity(0.4),
              fontSize: 14,
            ),
            filled: true,
            fillColor: AuthColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AuthColors.primaryBg, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AuthColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AuthColors.error, width: 1.5),
            ),
            prefixIcon: Icon(
              icon,
              color: AuthColors.textMuted.withOpacity(0.5),
              size: 20,
            ),
            suffixIcon: suffixWidget ??
                (toggleObscure != null
                    ? IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                          color: AuthColors.textMuted.withOpacity(0.5),
                          size: 20,
                        ),
                        onPressed: toggleObscure,
                      )
                    : null),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

/// زر الإرسال
class AuthSubmitButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.icon,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthColors.primaryBg,
          foregroundColor: AuthColors.accentYellow,
          disabledBackgroundColor: AuthColors.primaryBg.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AuthColors.accentYellow),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 20),
                ],
              ),
      ),
    );
  }
}

/// مؤشر قوة كلمة المرور
class PasswordStrengthIndicator extends StatelessWidget {
  final double strength;
  final List<String> errors;

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
    required this.errors,
  });

  @override
  Widget build(BuildContext context) {
    if (strength == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // شريط القوة
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength,
            backgroundColor: AuthColors.surfaceLow,
            valueColor: AlwaysStoppedAnimation<Color>(
              PasswordValidator.getStrengthColor(strength),
            ),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        // نص القوة
        Row(
          children: [
            Text(
              'قوة كلمة المرور: ',
              style: TextStyle(
                fontSize: 11,
                color: AuthColors.textMuted.withOpacity(0.7),
              ),
            ),
            Text(
              PasswordValidator.getStrengthText(strength),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: PasswordValidator.getStrengthColor(strength),
              ),
            ),
          ],
        ),
        // الأخطاء
        if (errors.isNotEmpty) ...[
          const SizedBox(height: 4),
          ...errors.map((error) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        size: 12, color: AuthColors.error.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(
                          fontSize: 11,
                          color: AuthColors.error.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}
