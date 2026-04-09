import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_icons.dart';
import '../../core/utils/navigation_helper.dart';
import '../../data/repositories/main_repository.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/certificate/certificate_bloc.dart';
import '../blocs/certificate/certificate_event.dart';
import '../blocs/course/course_bloc.dart';
import '../blocs/course/course_event.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_event.dart';
import '../widgets/index.dart';
import 'course_screen.dart';
import 'certificate/certificate_screen.dart';
import 'payments_screen.dart';
import 'settings_screen.dart';
import 'dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialTabIndex;
  const MainScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: AppIcons.dashboard, label: 'لوحة التحكم'),
    _NavItem(icon: AppIcons.courses, label: 'الدورات'),
    _NavItem(icon: AppIcons.certificates, label: 'الشهادات'),
    _NavItem(icon: Icons.payment, label: 'المدفوعات'),
    _NavItem(icon: AppIcons.settings, label: 'الإعدادات'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<CourseBloc>().add(CourseLoadRequested());
    context.read<CertificateBloc>().add(CertificateLoadRequested());
    context.read<SettingsBloc>().add(SettingsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          NavigationHelper.goToAuth(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: _buildAppBar(),
        body: _buildScreenContent(),
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 48),
      child: Container(
        color: AppTheme.darkBlue,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // الصف العلوي: معلومات المستخدم + الشعار
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // معلومات المستخدم (يمين)
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthAuthenticated) {
                          return _buildUserChip(state.user);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(width: 8),
                    // زر الإشعارات (يمين)
                    _buildNotificationButton(),
                    const Spacer(),
                    // شعار التطبيق (يسار)
                    const Text(
                      'وصلة',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.school, color: AppTheme.yellow, size: 28),
                  ],
                ),
              ),
              // شريط التنقل العلوي
              _buildTopNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(AppIcons.bell, color: AppTheme.white, size: 22),
          onPressed: _showNotificationsPanel,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserChip(dynamic user) {
    final initial =
        (user.name as String?)?.isNotEmpty == true ? user.name[0] : 'U';
    return GestureDetector(
      onTap: _showUserMenu,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppTheme.yellow,
            child: Text(
              initial.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            user.name ?? 'مستخدم',
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.keyboard_arrow_down,
              color: AppTheme.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildTopNavBar() {
    return SizedBox(
      height: 48,
      child: Row(
        children: List.generate(_navItems.length, (i) {
          final active = _currentIndex == i;
          final isPayments = i == 3; // زر المدفوعات

          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _currentIndex = i),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active ? AppTheme.yellow : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          _navItems[i].icon,
                          size: 18,
                          color: active
                              ? AppTheme.yellow
                              : AppTheme.white.withOpacity(0.6),
                        ),
                        // Badge للمدفوعات المعلقة - يظهر فقط عند وجود مدفوعات معلقة
                        if (isPayments)
                          FutureBuilder<int>(
                            future: _getPendingPaymentsCount(),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              if (count == 0) return const SizedBox.shrink();

                              return Positioned(
                                right: -6,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    count > 9 ? '9+' : count.toString(),
                                    style: const TextStyle(
                                      color: AppTheme.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _navItems[i].label,
                      style: TextStyle(
                        fontSize: 11,
                        color: active
                            ? AppTheme.yellow
                            : AppTheme.white.withOpacity(0.6),
                        fontWeight:
                            active ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── المحتوى ───────────────────────────────────────────────────────────────

  Widget _buildScreenContent() {
    switch (_currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const CourseScreen();
      case 2:
        return const CertificateScreen();
      case 3:
        return const PaymentsScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const DashboardScreen();
    }
  }

  // ─── Dialogs & Panels ──────────────────────────────────────────────────────

  void _showNotificationsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.borderRadiusLarge)),
      ),
      builder: (_) => const NotificationsPanel(),
    );
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 4);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.red),
            title: const Text('تسجيل الخروج',
                style: TextStyle(color: AppTheme.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  // الحصول على عدد المدفوعات المعلقة
  Future<int> _getPendingPaymentsCount() async {
    try {
      final repository = context.read<MainRepository>();
      final user = await repository.getUser();

      if (user != null) {
        final payments = await repository.getProviderPayments(user.id);
        return payments
            .where((p) => p.status.toString().contains('pending'))
            .length;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}

// ─── Helper classes ──────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class DrawerMenuItem {
  final IconData icon;
  final String title;
  final int index;
  DrawerMenuItem(
      {required this.icon, required this.title, required this.index});
}
