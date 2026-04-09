import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_icons.dart';
import '../../core/utils/navigation_helper.dart';
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
              // الصف العلوي: الشعار + معلومات المستخدم
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // شعار التطبيق
                    const Icon(Icons.school, color: AppTheme.yellow, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      'وصلة',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // زر الإشعارات
                    _buildNotificationButton(),
                    const SizedBox(width: 8),
                    // معلومات المستخدم
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthAuthenticated) {
                          return _buildUserChip(state.user);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
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
                    Icon(
                      _navItems[i].icon,
                      size: 18,
                      color: active
                          ? AppTheme.yellow
                          : AppTheme.white.withOpacity(0.6),
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
              setState(() => _currentIndex = 3);
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
