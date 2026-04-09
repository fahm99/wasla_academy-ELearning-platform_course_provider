import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/data/models/user.dart';
import 'package:course_provider/presentation/blocs/auth/auth_bloc.dart';
import 'package:course_provider/presentation/blocs/auth/auth_event.dart';
import 'package:course_provider/presentation/blocs/auth/auth_state.dart';
import 'package:course_provider/presentation/blocs/settings/settings_bloc.dart';
import 'package:course_provider/presentation/blocs/settings/settings_event.dart';
import 'package:course_provider/presentation/blocs/settings/settings_state.dart';
import 'package:course_provider/presentation/widgets/dialog_widgets.dart';
import 'package:course_provider/presentation/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:course_provider/core/utils/app_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:course_provider/data/repositories/main_repository.dart';

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
        physics: const BouncingScrollPhysics(),
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
          physics: const BouncingScrollPhysics(),
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
        color: Color(0xFF0C1445),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
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
        // صورة المستخدم مع زر التعديل
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: user.profileImageUrl != null &&
                        user.profileImageUrl!.isNotEmpty
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
            // زر تغيير الصورة
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _changeProfileImage(user),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF0C1445),
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingMedium),

        // اسم المستخدم
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.paddingSmall),

        // البريد الإلكتروني
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppTheme.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.email,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
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
            color: AppTheme.white.withOpacity(0.2),
            border: Border.all(
              color: AppTheme.white,
              width: 4,
            ),
          ),
          child: const Icon(
            Icons.person,
            size: 60,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),

        const Text(
          'مستخدم ضيف',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.paddingSmall),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppTheme.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'قم بتسجيل الدخول للوصول إلى جميع الميزات',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppTheme.paddingLarge),

        // إحصائيات افتراضية للضيف
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppTheme.yellow, AppTheme.yellow.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: AppTheme.darkBlue,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.darkBlue,
        unselectedLabelColor: AppTheme.darkGray,
        indicatorColor: AppTheme.yellow,
        indicatorWeight: 4,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        isScrollable: true,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: const [
          Tab(
            icon: Icon(Icons.settings, size: 20),
            text: 'عام',
          ),
          Tab(
            icon: Icon(Icons.notifications, size: 20),
            text: 'الإشعارات',
          ),
          Tab(
            icon: Icon(Icons.person, size: 20),
            text: 'الحساب',
          ),
          Tab(
            icon: Icon(Icons.payment, size: 20),
            text: 'الدفع',
          ),
          Tab(
            icon: Icon(Icons.info, size: 20),
            text: 'حول',
          ),
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
                        value: state.settings.notifyNewStudents,
                        onChanged: state.settings.notificationsEnabled
                            ? (value) {
                                context.read<SettingsBloc>().add(
                                      SettingsNotifyNewStudentsToggled(
                                          enabled: value),
                                    );
                              }
                            : null,
                      ),
                    ),
                    SettingItem(
                      icon: AppIcons.star,
                      title: 'تقييمات جديدة',
                      subtitle: 'عند تلقي تقييم جديد',
                      trailing: Switch(
                        value: state.settings.notifyNewReviews,
                        onChanged: state.settings.notificationsEnabled
                            ? (value) {
                                context.read<SettingsBloc>().add(
                                      SettingsNotifyNewReviewsToggled(
                                          enabled: value),
                                    );
                              }
                            : null,
                      ),
                    ),
                    SettingItem(
                      icon: Icons.money,
                      title: 'المدفوعات',
                      subtitle: 'عند تلقي دفعة جديدة',
                      trailing: Switch(
                        value: state.settings.notifyNewPayments,
                        onChanged: state.settings.notificationsEnabled
                            ? (value) {
                                context.read<SettingsBloc>().add(
                                      SettingsNotifyNewPaymentsToggled(
                                          enabled: value),
                                    );
                              }
                            : null,
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
            title: 'إعدادات الدفع',
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.yellow.withOpacity(0.1),
                      AppTheme.blue.withOpacity(0.1),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.yellow.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: AppTheme.darkBlue,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    const Text(
                      'إدارة معلومات الدفع',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      'قم بإعداد معلومات المحفظة والحساب البنكي لاستقبال المدفوعات من الطلاب',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGray.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push('/payment-settings');
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text(
                          'إدارة إعدادات الدفع',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.yellow,
                          foregroundColor: AppTheme.darkBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
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
            title: 'معلومات سريعة',
            children: [
              _buildInfoRow(
                icon: Icons.info_outline,
                title: 'طرق الدفع المتاحة',
                value: 'محفظة إلكترونية • تحويل بنكي',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.verified_user,
                title: 'التحقق من المدفوعات',
                value: 'يدوي من قبل مقدم الدورة',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.notifications_active,
                title: 'الإشعارات',
                value: 'تلقائية عند كل عملية دفع',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.darkBlue,
          size: 24,
        ),
        const SizedBox(width: AppTheme.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.darkGray.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppTheme.white,
              AppTheme.lightGray.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.yellow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              ...children,
            ],
          ),
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

  // تغيير صورة الملف الشخصي
  Future<void> _changeProfileImage(User user) async {
    final ImagePicker picker = ImagePicker();

    // عرض خيارات اختيار الصورة
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppTheme.darkBlue),
              title: const Text('اختيار من المعرض'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (image != null) {
                  await _uploadProfileImage(image, user);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.darkBlue),
              title: const Text('التقاط صورة'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (image != null) {
                  await _uploadProfileImage(image, user);
                }
              },
            ),
            if (user.profileImageUrl != null &&
                user.profileImageUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.red),
                title: const Text('حذف الصورة',
                    style: TextStyle(color: AppTheme.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteProfileImage(user);
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('إلغاء'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // رفع الصورة إلى Storage وتحديث قاعدة البيانات
  Future<void> _uploadProfileImage(XFile image, User user) async {
    try {
      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // رفع الصورة إلى Supabase Storage
      final repository = context.read<MainRepository>();
      final imageUrl = await repository.uploadProfileImage(
        userId: user.id,
        imagePath: image.path,
      );

      // تحديث معلومات المستخدم في قاعدة البيانات
      await repository.updateUserProfile(
        userId: user.id,
        profileImageUrl: imageUrl,
      );

      // تحديث حالة Auth
      context.read<AuthBloc>().add(AuthCheckStatus());

      // إخفاء مؤشر التحميل
      if (mounted) Navigator.pop(context);

      // عرض رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث صورة الملف الشخصي بنجاح'),
            backgroundColor: AppTheme.green,
          ),
        );
      }
    } catch (e) {
      // إخفاء مؤشر التحميل
      if (mounted) Navigator.pop(context);

      // عرض رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحديث الصورة: ${e.toString()}'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  // حذف صورة الملف الشخصي
  Future<void> _deleteProfileImage(User user) async {
    try {
      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // حذف الصورة من Storage وتحديث قاعدة البيانات
      final repository = context.read<MainRepository>();
      await repository.deleteProfileImage(userId: user.id);
      await repository.updateUserProfile(
        userId: user.id,
        profileImageUrl: null,
      );

      // تحديث حالة Auth
      context.read<AuthBloc>().add(AuthCheckStatus());

      // إخفاء مؤشر التحميل
      if (mounted) Navigator.pop(context);

      // عرض رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف صورة الملف الشخصي'),
            backgroundColor: AppTheme.green,
          ),
        );
      }
    } catch (e) {
      // إخفاء مؤشر التحميل
      if (mounted) Navigator.pop(context);

      // عرض رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في حذف الصورة: ${e.toString()}'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }
}
