import 'package:flutter/material.dart';

import '../widgets/auth_form_fields.dart';
import '../widgets/auth_hero_panel.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../widgets/forgot_password_dialog.dart';

/// شاشة المصادقة (تسجيل الدخول / إنشاء حساب)
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF8FF),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: BoxConstraints(maxWidth: isWide ? 960 : 480),
              decoration: BoxDecoration(
                color: AuthColors.surfaceCard,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0E1647).withOpacity(0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: isWide
                  ? IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(width: 380, child: AuthHeroPanel()),
                          Expanded(child: _buildFormPanel()),
                        ],
                      ),
                    )
                  : _buildFormPanel(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormPanel() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabSwitcher(),
              const SizedBox(height: 32),
              _buildFormTitle(),
              const SizedBox(height: 28),
              _tabController.index == 0
                  ? LoginForm(
                      onForgotPassword: () => showForgotPasswordDialog(context))
                  : const RegisterForm(),
              const SizedBox(height: 32),
              _buildFooterLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    final isLogin = _tabController.index == 0;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AuthColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _tabBtn('تسجيل الدخول', 0, isLogin),
          _tabBtn('حساب جديد', 1, !isLogin),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int index, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AuthColors.primaryBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AuthColors.primaryBg.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AuthColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormTitle() {
    final isLogin = _tabController.index == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLogin ? 'مرحباً بك مجدداً' : 'إنشاء حساب جديد',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0E1647),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isLogin
              ? 'يرجى إدخال بياناتك للوصول إلى حسابك كمدرب'
              : 'أنشئ حسابك وابدأ رحلتك التعليمية',
          style: const TextStyle(
              color: AuthColors.textMuted, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildFooterLinks() {
    final isLogin = _tabController.index == 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? 'ليس لديك حساب؟ ' : 'لديك حساب بالفعل؟ ',
          style: const TextStyle(fontSize: 13, color: AuthColors.textMuted),
        ),
        GestureDetector(
          onTap: () => _tabController.animateTo(isLogin ? 1 : 0),
          child: Text(
            isLogin ? 'أنشئ حساباً جديداً الآن' : 'تسجيل الدخول',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AuthColors.primaryBg,
              decoration: TextDecoration.underline,
              decorationColor: AuthColors.primaryBg,
            ),
          ),
        ),
      ],
    );
  }
}
