import 'package:flutter/material.dart';
import 'package:course_provider/utils/app_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../theme/Theme.dart';
import '../widgets/index.dart';
import '../models/index.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    context.read<SettingsBloc>().add(SettingsLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildGeneralSettingsTab(),
            _buildNotificationSettingsTab(),
            _buildAccountSettingsTab(),
            _buildPaymentSettingsTab(),
            _buildAboutTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // عنوان الصفحة
          const Center(
            child: Text(
              'الإعدادات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),

          // معلومات الملف الشخصي
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                return _buildUserProfileSection(authState.user);
              }
              return _buildGuestProfileSection();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(User user) {
    return Column(
      children: [
        // صورة المستخدم
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.darkBlue.withOpacity(0.2),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child:
                user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                    ? Image.network(
                        user.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar();
                        },
                      )
                    : _buildDefaultAvatar(),
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),

        // اسم المستخدم
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.paddingSmall),

        // البريد الإلكتروني
        Text(
          user.email,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.darkGray.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.paddingLarge),

        // الإحصائيات
      ],
    );
  }

  Widget _buildGuestProfileSection() {
    return Column(
      children: [
        // صورة افتراضية للضيف
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.lightGray,
            border: Border.all(
              color: AppTheme.darkBlue.withOpacity(0.2),
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.person,
            size: 60,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),

        const Text(
          'مستخدم ضيف',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.paddingSmall),

        Text(
          'قم بتسجيل الدخول للوصول إلى جميع الميزات',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.darkGray.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.paddingLarge),

        // إحصائيات افتراضية للضيف
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppTheme.darkBlue, AppTheme.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: AppTheme.white,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.darkBlue,
        unselectedLabelColor: AppTheme.darkGray,
        indicatorColor: AppTheme.yellow,
        indicatorWeight: 3,
        isScrollable: true,
        tabs: const [
          Tab(text: 'عام'),
          Tab(text: 'الإشعارات'),
          Tab(text: 'الحساب'),
          Tab(text: 'معلومات الدفع'),
          Tab(text: 'حول التطبيق'),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsTab() {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.red,
            ),
          );
        } else if (state is SettingsUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SettingsLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              children: [
                _buildSettingsCard(
                  title: 'المظهر والعرض',
                  children: [
                    SettingItem(
                      icon: Icons.palette,
                      title: 'المظهر',
                      subtitle: 'اختر المظهر المفضل لديك',
                      trailing: DropdownButton<String>(
                        value: state.settings.theme,
                        items: const [
                          DropdownMenuItem(value: 'light', child: Text('فاتح')),
                          DropdownMenuItem(value: 'dark', child: Text('داكن')),
                          DropdownMenuItem(
                              value: 'system', child: Text('النظام')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsBloc>().add(
                                  SettingsThemeChanged(theme: value),
                                );
                          }
                        },
                      ),
                    ),
                    SettingItem(
                      icon: Icons.language,
                      title: 'اللغة',
                      subtitle: 'اختر لغة التطبيق',
                      trailing: DropdownButton<String>(
                        value: state.settings.language,
                        items: const [
                          DropdownMenuItem(value: 'ar', child: Text('العربية')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsBloc>().add(
                                  SettingsLanguageChanged(language: value),
                                );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                _buildSettingsCard(
                  title: 'الحفظ والمزامنة',
                  children: [
                    SettingItem(
                      icon: Icons.save,
                      title: 'الحفظ التلقائي',
                      subtitle: 'حفظ التغييرات تلقائياً',
                      trailing: Switch(
                        value: state.settings.autoSave,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(
                                SettingsAutoSaveToggled(enabled: value),
                              );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                _buildSettingsCard(
                  title: 'إدارة البيانات',
                  children: [
                    SettingItem(
                      icon: Icons.redo,
                      title: 'إعادة تعيين الإعدادات',
                      subtitle: 'استعادة الإعدادات الافتراضية',
                      onTap: () => _showResetDialog(),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildNotificationSettingsTab() {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              children: [
                _buildSettingsCard(
                  title: 'الإشعارات العامة',
                  children: [
                    SettingItem(
                      icon: AppIcons.bell,
                      title: 'تفعيل الإشعارات',
                      subtitle: 'تلقي جميع الإشعارات',
                      trailing: Switch(
                        value: state.settings.notificationsEnabled,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(
                                SettingsNotificationsToggled(enabled: value),
                              );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                _buildSettingsCard(
                  title: 'أنواع الإشعارات',
                  children: [
                    SettingItem(
                      icon: Icons.event_available_outlined,
                      title: 'إشعارات البريد الإلكتروني',
                      subtitle: 'تلقي الإشعارات عبر البريد الإلكتروني',
                      trailing: Switch(
                        value: state.settings.emailNotifications,
                        onChanged: state.settings.notificationsEnabled
                            ? (value) {
                                context.read<SettingsBloc>().add(
                                      SettingsEmailNotificationsToggled(
                                          enabled: value),
                                    );
                              }
                            : null,
                      ),
                    ),
                    SettingItem(
                      icon: Icons.mobile_friendly,
                      title: 'الإشعارات الفورية',
                      subtitle: 'تلقي الإشعارات على الجهاز',
                      trailing: Switch(
                        value: state.settings.pushNotifications,
                        onChanged: state.settings.notificationsEnabled
                            ? (value) {
                                context.read<SettingsBloc>().add(
                                      SettingsPushNotificationsToggled(
                                          enabled: value),
                                    );
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                _buildSettingsCard(
                  title: 'إشعارات محددة',
                  children: [
                    SettingItem(
                      icon: AppIcons.publish,
                      title: 'طلاب جدد',
                      subtitle: 'عند انضمام طالب جديد',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                      ),
                    ),
                    SettingItem(
                      icon: AppIcons.star,
                      title: 'تقييمات جديدة',
                      subtitle: 'عند تلقي تقييم جديد',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                      ),
                    ),
                    SettingItem(
                      icon: Icons.money,
                      title: 'المدفوعات',
                      subtitle: 'عند تلقي دفعة جديدة',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAccountSettingsTab() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              children: [
                _buildSettingsCard(
                  title: 'معلومات الحساب',
                  children: [
                    ProfileHeader(user: authState.user),
                    const SizedBox(height: AppTheme.paddingMedium),
                    SettingItem(
                      icon: AppIcons.edit,
                      title: 'تعديل الملف الشخصي',
                      subtitle: 'تحديث معلوماتك الشخصية',
                      onTap: () => _showEditProfileDialog(authState.user),
                    ),
                    SettingItem(
                      icon: Icons.key,
                      title: 'تغيير كلمة المرور',
                      subtitle: 'تحديث كلمة المرور الخاصة بك',
                      onTap: () => _showChangePasswordDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                _buildSettingsCard(
                  title: 'الأمان والخصوصية',
                  children: [
                    SettingItem(
                      icon: Icons.shield,
                      title: 'المصادقة الثنائية',
                      subtitle: 'تأمين إضافي لحسابك',
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {},
                      ),
                    ),
                    SettingItem(
                      icon: Icons.history,
                      title: 'سجل تسجيل الدخول',
                      subtitle: 'عرض آخر عمليات تسجيل الدخول',
                      onTap: () => _showLoginHistoryDialog(),
                    ),
                    SettingItem(
                      icon: Icons.security,
                      title: 'سياسة الخصوصية',
                      subtitle: 'اطلع على سياسة الخصوصية',
                      onTap: () => _showPrivacyPolicyDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                _buildSettingsCard(
                  title: 'إدارة الحساب',
                  children: [
                    SettingItem(
                      icon: Icons.logout,
                      title: 'تسجيل الخروج',
                      subtitle: 'تسجيل الخروج من جميع الأجهزة',
                      onTap: () => _showLogoutDialog(),
                    ),
                    SettingItem(
                      icon: Icons.delete,
                      title: 'حذف الحساب',
                      subtitle: 'حذف الحساب نهائياً',
                      onTap: () => _showDeleteAccountDialog(),
                      textColor: AppTheme.red,
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildPaymentSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        children: [
          _buildSettingsCard(
            title: 'طريقة الدفع المفضلة',
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.darkGray.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.keyboard_arrow_down,
                        color: AppTheme.darkGray),
                    const SizedBox(width: AppTheme.paddingSmall),
                    const Text(
                      'تحويل بنكي',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'مفعل',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          _buildSettingsCard(
            title: 'معلومات البنك',
            children: [
              _buildPaymentInfoField(
                label: 'اسم البنك',
                value: 'البنك الأهلي التجاري',
                icon: Icons.account_balance,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              _buildPaymentInfoField(
                label: 'رقم الحساب',
                value: 'SA1234567890123456789012',
                icon: Icons.credit_card,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              _buildPaymentInfoField(
                label: 'الآيبان (IBAN)',
                value: 'SA6512345678901234567890',
                icon: Icons.account_balance_wallet,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              _buildPaymentInfoField(
                label: 'حد السحب الشهري (ريال يمني)',
                value: '500000',
                icon: Icons.money,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showSaveChangesDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.yellow,
                foregroundColor: AppTheme.darkBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'حفظ التغييرات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.darkGray.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.darkGray,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSaveChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حفظ التغييرات'),
        content: const Text('هل تريد حفظ التغييرات على معلومات الدفع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ التغييرات بنجاح'),
                  backgroundColor: AppTheme.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.yellow,
              foregroundColor: AppTheme.darkBlue,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        children: [
          _buildSettingsCard(
            title: 'معلومات التطبيق',
            children: [
              const AboutAppHeader(),
              const SizedBox(height: AppTheme.paddingMedium),
              const SettingItem(
                icon: Icons.info,
                title: 'الإصدار',
                subtitle: '1.0.0',
              ),
              const SettingItem(
                icon: AppIcons.calendar,
                title: 'تاريخ الإصدار',
                subtitle: '2024/01/01',
              ),
              const SettingItem(
                icon: Icons.code,
                title: 'رقم البناء',
                subtitle: '100',
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          _buildSettingsCard(
            title: 'الدعم والمساعدة',
            children: [
              SettingItem(
                icon: AppIcons.quiz,
                title: 'الأسئلة الشائعة',
                subtitle: 'إجابات على الأسئلة الأكثر شيوعاً',
                onTap: () => _showFAQDialog(),
              ),
              SettingItem(
                icon: Icons.support,
                title: 'الدعم الفني',
                subtitle: 'تواصل مع فريق الدعم',
                onTap: () => _showSupportDialog(),
              ),
              SettingItem(
                icon: Icons.error,
                title: 'الإبلاغ عن مشكلة',
                subtitle: 'أرسل تقرير عن مشكلة تقنية',
                onTap: () => _showBugReportDialog(),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          _buildSettingsCard(
            title: 'القانونية',
            children: [
              SettingItem(
                icon: Icons.file_open_outlined,
                title: 'الشروط والأحكام',
                subtitle: 'اطلع على شروط الاستخدام',
                onTap: () => _showTermsDialog(),
              ),
              SettingItem(
                icon: Icons.security,
                title: 'سياسة الخصوصية',
                subtitle: 'كيف نحمي بياناتك',
                onTap: () => _showPrivacyPolicyDialog(),
              ),
              const SettingItem(
                icon: Icons.copyright,
                title: 'حقوق الطبع والنشر',
                subtitle: '© 2024 وصلة. جميع الحقوق محفوظة',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الإعدادات'),
        content: const Text(
          'هل أنت متأكد من رغبتك في إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SettingsBloc>().add(SettingsResetRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        user: user,
        onSave: (updatedUser) {
          // تحديث بيانات المستخدم
        },
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _showLoginHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => const LoginHistoryDialog(),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => const PrivacyPolicyDialog(),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );
  }

  void _showFAQDialog() {
    showDialog(
      context: context,
      builder: (context) => const FAQDialog(),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => const SupportDialog(),
    );
  }

  void _showBugReportDialog() {
    showDialog(
      context: context,
      builder: (context) => const BugReportDialog(),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => const TermsDialog(),
    );
  }
}
