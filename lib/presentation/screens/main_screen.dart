import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../core/theme/app_theme.dart';
import '../../core/utils/navigation_helper.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/course/course_bloc.dart';
import '../blocs/course/course_event.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_event.dart';
import '../widgets/index.dart';
import 'course_screen.dart';
import 'all_certificates_screen.dart';
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
    _NavItem(icon: Icons.dashboard, label: 'الرئيسية', iconFilled: true),
    _NavItem(icon: Icons.menu_book, label: 'الكورسات', iconFilled: false),
    _NavItem(
        icon: Icons.workspace_premium, label: 'الشهادات', iconFilled: false),
    _NavItem(icon: Icons.payments, label: 'المدفوعات', iconFilled: false),
    _NavItem(icon: Icons.settings, label: 'الإعدادات', iconFilled: false),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<CourseBloc>().add(CourseLoadRequested());
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
        backgroundColor: const Color(0xFFF9F9F9),
        body: Column(
          children: [
            // Desktop AppBar
            if (MediaQuery.of(context).size.width >= 768) _buildDesktopAppBar(),
            // Mobile Header
            if (MediaQuery.of(context).size.width < 768) _buildMobileHeader(),
            // Content
            Expanded(child: _buildScreenContent()),
          ],
        ),
        // Mobile Bottom Navigation
        bottomNavigationBar: MediaQuery.of(context).size.width < 768
            ? _buildMobileBottomNav()
            : null,
      ),
    );
  }

  // ─── Desktop AppBar ────────────────────────────────────────────────────────

  Widget _buildDesktopAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C1445).withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              children: [
                // Logo (Left in RTL)
                Text(
                  'وصلة',
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.darkBlue,
                  ),
                ),
                const SizedBox(width: 24),
                // Navigation Links
                Expanded(
                  child: _buildDesktopNavLinks(),
                ),
                const SizedBox(width: 24),
                // Right Side: Search, Notifications, Profile, Logout
                _buildDesktopRightSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopNavLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < _navItems.length; i++) ...[
          _buildDesktopNavLink(i),
          if (i < _navItems.length - 1) const SizedBox(width: 24),
        ],
      ],
    );
  }

  Widget _buildDesktopNavLink(int index) {
    final isActive = _currentIndex == index;
    final item = _navItems[index];

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  bottom: BorderSide(
                    color: Color(0xFFFFD54F),
                    width: 2,
                  ),
                )
              : null,
        ),
        child: Text(
          item.label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppTheme.darkBlue : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopRightSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final userName = user?.name ?? 'مستخدم';
        final userInitial = userName.isNotEmpty ? userName[0] : 'U';

        return Row(
          children: [
            // Search Bar
            Container(
              width: 250,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.search,
                    color: Color(0xFF454652),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن كورس أو طالب...',
                        hintStyle: GoogleFonts.cairo(
                          fontSize: 13,
                          color: const Color(0xFF454652),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.only(bottom: 8),
                      ),
                      style: GoogleFonts.cairo(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Notifications
            IconButton(
              onPressed: _showNotificationsPanel,
              icon: const Icon(Icons.notifications, size: 22),
              color: const Color(0xFF454652),
              tooltip: 'الإشعارات',
            ),
            const SizedBox(width: 8),
            // Divider
            Container(
              width: 1,
              height: 40,
              color: const Color(0xFFC6C5D4).withOpacity(0.3),
            ),
            const SizedBox(width: 16),
            // Profile
            InkWell(
              onTap: _showUserMenu,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.yellow,
                    child: Text(
                      userInitial.toUpperCase(),
                      style: GoogleFonts.cairo(
                        color: AppTheme.darkBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      Text(
                        'مقدم خدمة',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: const Color(0xFF454652),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Logout
            TextButton(
              onPressed: _showLogoutDialog,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                'تسجيل الخروج',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Mobile Header ─────────────────────────────────────────────────────────

  Widget _buildMobileHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C1445).withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Text(
                    'وصلة',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  // Right Side: Notifications + Profile
                  Row(
                    children: [
                      IconButton(
                        onPressed: _showNotificationsPanel,
                        icon: const Icon(Icons.notifications, size: 20),
                        color: const Color(0xFF454652),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final user =
                              state is AuthAuthenticated ? state.user : null;
                          final userName = user?.name ?? 'مستخدم';
                          final userInitial =
                              userName.isNotEmpty ? userName[0] : 'U';

                          return GestureDetector(
                            onTap: _showUserMenu,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.yellow,
                              child: Text(
                                userInitial.toUpperCase(),
                                style: GoogleFonts.cairo(
                                  color: AppTheme.darkBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Mobile Bottom Navigation ──────────────────────────────────────────────

  Widget _buildMobileBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFC6C5D4).withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < _navItems.length; i++)
                    _buildMobileNavItem(i),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(int index) {
    final isActive = _currentIndex == index;
    final item = _navItems[index];

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.darkBlue.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? const Border(
                    top: BorderSide(
                      color: AppTheme.yellow,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 20,
                color: isActive ? AppTheme.darkBlue : const Color(0xFF94A3B8),
                fill: item.iconFilled && isActive ? 1.0 : 0.0,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? AppTheme.darkBlue : const Color(0xFF94A3B8),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
        return const AllCertificatesScreen();
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
  final bool iconFilled;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.iconFilled,
  });
}

class DrawerMenuItem {
  final IconData icon;
  final String title;
  final int index;
  DrawerMenuItem(
      {required this.icon, required this.title, required this.index});
}
