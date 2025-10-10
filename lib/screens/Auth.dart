import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../theme/Theme.dart';
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

  // حقول تسجيل الدخول
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscureLoginPassword = true;

  // حقول التسجيل
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  // نسيان كلمة المرور
  final _forgotEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusXLarge),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingXLarge),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppTheme.paddingLarge),
                        _buildTabBar(),
                        const SizedBox(height: AppTheme.paddingLarge),
                        _buildTabBarView(),
                        const SizedBox(height: AppTheme.paddingMedium),
                        _buildSocialLogin(),
                        const SizedBox(height: AppTheme.paddingMedium),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.darkBlue,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
          child: const Icon(
            Icons.school,
            color: AppTheme.yellow,
            size: 40,
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        const Text(
          'وصلة',
          style: AppTheme.authTitle,
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        const Text(
          'منصة مقدمي الخدمات التعليمية',
          style: AppTheme.authSubtitle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.mediumGray,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.darkBlue,
        unselectedLabelColor: AppTheme.darkGray,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          fontFamily: 'Cairo',
        ),
        indicatorColor: AppTheme.yellow,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'تسجيل الدخول'),
          Tab(text: 'إنشاء حساب'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginForm(),
          _buildRegisterForm(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.red,
            ),
          );
        } else if (state is AuthAuthenticated) {
          // Use the new navigation helper
          NavigationHelper.goToMain(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: _loginFormKey,
          child: Column(
            children: [
              const SizedBox(height: AppTheme.paddingMedium),
              CustomTextField(
                controller: _loginEmailController,
                label: 'البريد الإلكتروني',
                hint: 'أدخل بريدك الإلكتروني',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'يرجى إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              CustomTextField(
                controller: _loginPasswordController,
                label: 'كلمة المرور',
                hint: 'أدخل كلمة المرور',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureLoginPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureLoginPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 16,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureLoginPassword = !_obscureLoginPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  if (value.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Text('تذكرني'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showForgotPasswordDialog(),
                    child: const Text('نسيت كلمة المرور؟'),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.darkBlue),
                          ),
                        )
                      : const Text('تسجيل الدخول'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegisterForm() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.red,
            ),
          );
        } else if (state is AuthAuthenticated) {
          // Use the new navigation helper
          NavigationHelper.goToMain(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: _registerFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: AppTheme.paddingMedium),
                CustomTextField(
                  controller: _registerNameController,
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك الكامل',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الاسم الكامل';
                    }
                    if (value.length < 3) {
                      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                CustomTextField(
                  controller: _registerEmailController,
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل بريدك الإلكتروني',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'يرجى إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                CustomTextField(
                  controller: _registerPhoneController,
                  label: 'رقم الهاتف',
                  hint: '+966501234567',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    if (!RegExp(r'^\+966[0-9]{9}$').hasMatch(value)) {
                      return 'يرجى إدخال رقم هاتف صحيح (+966xxxxxxxxx)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                CustomTextField(
                  controller: _registerPasswordController,
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureRegisterPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureRegisterPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 16,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureRegisterPassword = !_obscureRegisterPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                CustomTextField(
                  controller: _registerConfirmPasswordController,
                  label: 'تأكيد كلمة المرور',
                  hint: 'أعد إدخال كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 16,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى تأكيد كلمة المرور';
                    }
                    if (value != _registerPasswordController.text) {
                      return 'كلمة المرور غير متطابقة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptTerms = !_acceptTerms;
                          });
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: AppTheme.darkGray,
                              fontSize: 14,
                              fontFamily: 'Cairo',
                            ),
                            children: [
                              TextSpan(text: 'أوافق على '),
                              TextSpan(
                                text: 'الشروط والأحكام',
                                style: TextStyle(
                                  color: AppTheme.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' و '),
                              TextSpan(
                                text: 'سياسة الخصوصية',
                                style: TextStyle(
                                  color: AppTheme.blue,
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
                const SizedBox(height: AppTheme.paddingLarge),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (isLoading || !_acceptTerms) ? null : _handleRegister,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.darkBlue),
                            ),
                          )
                        : const Text('إنشاء حساب'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: AppTheme.mediumGray)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
              child: Text(
                'أو',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            Expanded(child: Divider(color: AppTheme.mediumGray)),
          ],
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              color: Colors.red,
              onPressed: () {
                // تسجيل الدخول بـ Google
              },
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            _buildSocialButton(
              icon: Icons.apple,
              color: Colors.black,
              onPressed: () {
                // تسجيل الدخول بـ Apple
              },
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            _buildSocialButton(
              icon: Icons.window,
              color: Colors.blue,
              onPressed: () {
                // تسجيل الدخول بـ Microsoft
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.mediumGray),
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      'جميع الحقوق محفوظة © 2024 وصلة',
      style: TextStyle(
        color: AppTheme.darkGray,
        fontSize: 12,
        fontFamily: 'Cairo',
      ),
      textAlign: TextAlign.center,
    );
  }

  void _handleLogin() {
    if (_loginFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _loginEmailController.text.trim(),
              password: _loginPasswordController.text,
            ),
          );
    }
  }

  void _handleRegister() {
    if (_registerFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              name: _registerNameController.text.trim(),
              email: _registerEmailController.text.trim(),
              password: _registerPasswordController.text,
              phone: _registerPhoneController.text.trim(),
            ),
          );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نسيان كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور',
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            CustomTextField(
              controller: _forgotEmailController,
              label: 'البريد الإلكتروني',
              hint: 'أدخل بريدك الإلكتروني',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_forgotEmailController.text.isNotEmpty) {
                context.read<AuthBloc>().add(
                      AuthForgotPassword(
                          email: _forgotEmailController.text.trim()),
                    );
                Navigator.of(context).pop();
              }
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }
}
