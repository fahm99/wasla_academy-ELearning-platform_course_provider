import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../widgets/index.dart';
import '../utils/navigation_helper.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscureLoginPassword = true;

  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  final _forgotEmailController = TextEditingController();

  // الألوان مطابقة للتصميم في الصورة
  static const _primaryBg = Color(0xFF0E1647);
  static const _accentYellow = Color(0xFFFFDB23);
  static const _surfaceLow = Color(0xFFF4F2FF);
  static const _surfaceCard = Color(0xFFFFFFFF);
  static const _textMuted = Color(0xFF46464F);
  static const _inputBg = Color(0xFFF4F2FF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _registerPhoneController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    return Directionality(
      textDirection: TextDirection.rtl, // RTL بالكامل
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF8FF),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: BoxConstraints(maxWidth: isWide ? 960 : 480),
              decoration: BoxDecoration(
                color: _surfaceCard,
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
                          // الهيرو على اليمين في RTL
                          SizedBox(
                            width: 380,
                            child: _buildHeroPanel(),
                          ),
                          // النموذج على اليسار في RTL
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

  // ─── لوحة الهيرو (اليمين في الوضع العريض) ───────────────────────────────────

  Widget _buildHeroPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: _primaryBg,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Wasla',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'بوابتك للتميز في التعليم',
            style: TextStyle(
              color: _accentYellow,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 48),
          _buildHeroFeature(
            icon: Icons.school_outlined,
            title: 'إدارة الدورات بسلاسة',
            subtitle: 'أدوات متقدمة لتنظيم محتواك التعليمي وتقديمه بأفضل صورة.',
          ),
          const SizedBox(height: 28),
          _buildHeroFeature(
            icon: Icons.trending_up_rounded,
            title: 'تحليلات دقيقة للأداء',
            subtitle: 'راقب تقدم طلابك وحقق أهدافك من خلال لوحة بيانات ذكية.',
          ),
          const SizedBox(height: 40),
          // الصورة
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/prov.png',
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroFeature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الأيقونة على اليمين (في RTL)
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _accentYellow, size: 24),
        ),
        const SizedBox(width: 16),
        // النصوص
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── لوحة النموذج (اليسار في الوضع العريض) ──────────────────────────────────

  Widget _buildFormPanel() {
    return Padding(
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
                ? _buildLoginForm()
                : _buildRegisterForm(),
            const SizedBox(height: 32),
            _buildFooterLinks(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    final isLogin = _tabController.index == 0;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surfaceLow,
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
            color: active ? _primaryBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _primaryBg.withOpacity(0.25),
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
              color: active ? Colors.white : _textMuted,
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
          style: const TextStyle(color: _textMuted, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  // ─── نموذج تسجيل الدخول ───────────────────────────────────────────────────

  Widget _buildLoginForm() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ));
        } else if (state is AuthAuthenticated) {
          NavigationHelper.goToMain(context);
        } else if (state is AuthPasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('تم إرسال رابط إعادة التعيين إلى ${state.email}'),
            backgroundColor: Colors.green,
          ));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _newField(
                controller: _loginEmailController,
                label: 'البريد الإلكتروني',
                hint: 'example@wasla.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'يرجى إدخال البريد الإلكتروني';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
                    return 'بريد إلكتروني غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _newField(
                controller: _loginPasswordController,
                label: 'كلمة المرور',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscureLoginPassword,
                toggleObscure: () => setState(
                    () => _obscureLoginPassword = !_obscureLoginPassword),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'يرجى إدخال كلمة المرور';
                  if (v.length < 6)
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // تذكرني على اليمين
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v),
                          activeColor: _primaryBg,
                          activeTrackColor: _primaryBg.withOpacity(0.3),
                        ),
                      ),
                      const Text('تذكرني',
                          style: TextStyle(fontSize: 13, color: _textMuted)),
                    ],
                  ),
                  const Spacer(),
                  // نسيت كلمة المرور على اليسار
                  TextButton(
                    onPressed: _showForgotPasswordDialog,
                    style: TextButton.styleFrom(
                      foregroundColor: _primaryBg,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('نسيت كلمة المرور؟',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _submitButton(
                label: 'دخول للمنصة',
                icon: Icons.arrow_back_rounded, // سهم يشير لليسار في RTL
                isLoading: isLoading,
                onPressed: _handleLogin,
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── نموذج إنشاء الحساب ───────────────────────────────────────────────────

  Widget _buildRegisterForm() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ));
        } else if (state is AuthAuthenticated) {
          NavigationHelper.goToMain(context);
        } else if (state is AuthRegistrationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ));
          _tabController.animateTo(0);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Form(
          key: _registerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _newField(
                controller: _registerNameController,
                label: 'الاسم الكامل',
                hint: 'أدخل اسمك الكامل',
                icon: Icons.person_outline_rounded,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'يرجى إدخال الاسم الكامل';
                  if (v.length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _newField(
                controller: _registerEmailController,
                label: 'البريد الإلكتروني',
                hint: 'example@wasla.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'يرجى إدخال البريد الإلكتروني';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
                    return 'بريد إلكتروني غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _newField(
                controller: _registerPhoneController,
                label: 'رقم الهاتف',
                hint: '+967xxxxxxxxx',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'يرجى إدخال رقم الهاتف';
                  if (!RegExp(r'^\+967[0-9]{9}$').hasMatch(v))
                    return 'رقم هاتف غير صحيح (+967xxxxxxxxx)';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _newField(
                controller: _registerPasswordController,
                label: 'كلمة المرور',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscureRegisterPassword,
                toggleObscure: () => setState(
                    () => _obscureRegisterPassword = !_obscureRegisterPassword),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'يرجى إدخال كلمة المرور';
                  if (v.length < 6)
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _newField(
                controller: _registerConfirmPasswordController,
                label: 'تأكيد كلمة المرور',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscureConfirmPassword,
                toggleObscure: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'يرجى تأكيد كلمة المرور';
                  if (v != _registerPasswordController.text)
                    return 'كلمة المرور غير متطابقة';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                    activeColor: _primaryBg,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 13, color: _textMuted),
                          children: [
                            TextSpan(text: 'أوافق على '),
                            TextSpan(
                              text: 'الشروط والأحكام',
                              style: TextStyle(
                                  color: _primaryBg,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                            TextSpan(text: ' و '),
                            TextSpan(
                              text: 'سياسة الخصوصية',
                              style: TextStyle(
                                  color: _primaryBg,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _submitButton(
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

  // ─── Widgets مساعدة ───────────────────────────────────────────────────────

  Widget _newField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _textMuted,
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: _textMuted.withOpacity(0.4), fontSize: 14),
            filled: true,
            fillColor: _inputBg,
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
              borderSide: const BorderSide(color: _primaryBg, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            // في RTL: prefixIcon يظهر على اليمين
            prefixIcon: Icon(icon, color: _textMuted.withOpacity(0.5), size: 20),
            suffixIcon: toggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: _textMuted.withOpacity(0.5),
                      size: 20,
                    ),
                    onPressed: toggleObscure,
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _submitButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBg,
          foregroundColor: _accentYellow,
          disabledBackgroundColor: _primaryBg.withOpacity(0.5),
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
                  valueColor: AlwaysStoppedAnimation<Color>(_accentYellow),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Icon(icon, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    final isLogin = _tabController.index == 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? 'ليس لديك حساب؟ ' : 'لديك حساب بالفعل؟ ',
          style: const TextStyle(fontSize: 13, color: _textMuted),
        ),
        GestureDetector(
          onTap: () => _tabController.animateTo(isLogin ? 1 : 0),
          child: Text(
            isLogin ? 'أنشئ حساباً جديداً الآن' : 'تسجيل الدخول',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _primaryBg,
              decoration: TextDecoration.underline,
              decorationColor: _primaryBg,
            ),
          ),
        ),
      ],
    );
  }

  // ─── المنطق (محفوظ كما هو) ─────────────────────────────────────────────────

  void _handleLogin() {
    if (_loginFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthLoginRequested(
            email: _loginEmailController.text.trim(),
            password: _loginPasswordController.text,
          ));
    }
  }

  void _handleRegister() {
    if (_registerFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthRegisterRequested(
            name: _registerNameController.text.trim(),
            email: _registerEmailController.text.trim(),
            password: _registerPasswordController.text,
            phone: _registerPhoneController.text.trim(),
            userType: 'provider',
          ));
    }
  }

  void _showForgotPasswordDialog() {
    _forgotEmailController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (ctx, state) {
            if (state is AuthPasswordResetSent) {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('تم إرسال رابط إعادة التعيين إلى ${state.email}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ));
            } else if (state is AuthError) {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ));
            }
          },
          builder: (ctx, state) {
            final isLoading = state is AuthLoading;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title:
                  const Text('استعادة كلمة المرور', textAlign: TextAlign.right),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 13, color: _textMuted),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _forgotEmailController,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      hintText: 'example@wasla.com',
                      filled: true,
                      fillColor: _inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.mail_outline_rounded, 
                          color: _textMuted.withOpacity(0.5)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_forgotEmailController.text.isNotEmpty) {
                            ctx.read<AuthBloc>().add(AuthForgotPassword(
                                email: _forgotEmailController.text.trim()));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBg,
                      foregroundColor: _accentYellow),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_accentYellow)))
                      : const Text('إرسال'),
                ),
              ],
              actionsAlignment: MainAxisAlignment.start,
            );
          },
        ),
      ),
    );
  }
}