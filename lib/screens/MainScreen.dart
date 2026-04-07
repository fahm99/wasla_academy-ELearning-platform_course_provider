import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../theme/Theme.dart';
import '../widgets/index.dart';
import '../utils/app_icons.dart';
import '../utils/navigation_helper.dart';
import '../models/index.dart';
import 'Course.dart';
import 'Certificate.dart';
import 'Settings.dart';
import 'DashboardScreen.dart';

class MainScreen extends StatefulWidget {
  final int initialTabIndex;

  const MainScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _currentIndex;
  late AnimationController _sidebarController;
  late Animation<Offset> _sidebarOffsetAnimation;
  bool _isSidebarOpen = false;
  bool _isTabletMode = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    // Initialize sidebar animation controller
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sidebarOffsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeInOut,
    ));
    // تحميل البيانات الأولية
    _loadInitialData();
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // إغلاق الـ Drawer إذا تم تغيير حجم الشاشة إلى ديسكتوب
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 768 && _scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }

    // Check screen size and update sidebar mode
    final isTablet = screenWidth >= 600 && screenWidth < 768;

    if (isTablet && !_isTabletMode) {
      // Switched to tablet mode
      setState(() {
        _isTabletMode = true;
        _isSidebarOpen = false;
        _sidebarController.reset();
      });
    } else if (!isTablet && _isTabletMode) {
      // Switched from tablet mode
      setState(() {
        _isTabletMode = false;
      });
    }

    // Close sidebar if it was open when switching to desktop
    if (screenWidth >= 768 && _isSidebarOpen) {
      _closeSidebar();
    }
  }

  void _loadInitialData() {
    context.read<CourseBloc>().add(CourseLoadRequested());
    // Removed StudentBloc loading
    context.read<CertificateBloc>().add(CertificateLoadRequested());
    context.read<SettingsBloc>().add(SettingsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;
    final isTablet = screenWidth >= 600 && screenWidth < 768;

    // Check if we're on web or desktop platform
    const isWebOrDesktop = kIsWeb || !kIsWeb; // Simplified check for now

    // For web/desktop, we want to show sidebar instead of bottom nav
    final showSidebarPermanently = isDesktop && isWebOrDesktop;

    // Check if we should show the sidebar (tablet mode or sidebar is open)
    final showSidebar = isTablet || _isSidebarOpen || showSidebarPermanently;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // إذا لم نكن في التبويب الأول، انتقل إليه
        if (_currentIndex != 0) {
          _navigateToTab(0);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(),
        // Remove the endDrawer since we're implementing our own sidebar
        body: GestureDetector(
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: Stack(
            children: [
              // Main content
              _buildMainContent(),
              // Sidebar overlay for mobile (slides in from right)
              if (showSidebar && !_isTabletMode && !showSidebarPermanently)
                SlideTransition(
                  position: _sidebarOffsetAnimation,
                  child: _buildSidebar(),
                ),
              // Sidebar for tablet mode (always visible on the left)
              if ((_isTabletMode || showSidebarPermanently) &&
                  screenWidth >= 768)
                Positioned.directional(
                  textDirection: TextDirection.rtl,
                  start: 0,
                  top: 0,
                  bottom: 0,
                  child: _buildSidebar(),
                ),
            ],
          ),
        ),
        // Show bottom navigation only on mobile devices
        bottomNavigationBar:
            (isDesktop && isWebOrDesktop) ? null : _buildBottomNavigation(),
      ),
    );
  }

  AppBar _buildAppBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;
    const isWebOrDesktop = kIsWeb || !kIsWeb; // Simplified check for now
    final showSidebarPermanently = isDesktop && isWebOrDesktop;

    return AppBar(
      backgroundColor: AppTheme.darkBlue,
      foregroundColor: AppTheme.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppTheme.white),
      // Never show back button on main screens
      automaticallyImplyLeading: false,
      leading: showSidebarPermanently && screenWidth >= 768
          ? null
          : IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // For mobile/tablet, toggle sidebar
                if (_isSidebarOpen) {
                  _closeSidebar();
                } else {
                  _openSidebar();
                }
              },
            ),
      actions: [
        // زر الإشعارات مع badge
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(
                  AppIcons.bell,
                  size: 24,
                  color: AppTheme.white,
                ),
                onPressed: () {
                  _showNotificationsPanel();
                },
              ),
              // Badge للإشعارات
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppTheme.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        // ملف المستخدم
        Container(
          margin: const EdgeInsets.only(right: 16, left: 8),
          child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
            if (state is AuthAuthenticated) {
              return _buildUserProfile(state.user);
            }
            return _buildGuestProfile();
          }),
        ),
      ],
    );
  }

  Widget _buildUserProfile(dynamic user) {
    return GestureDetector(
      onTap: () {
        _showUserMenu();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.white,
              child: Text(
                user.name?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name ?? 'مستخدم',
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    _getUserTypeText(user.type),
                    style: TextStyle(
                      color: AppTheme.white.withOpacity(0.8),
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.white.withOpacity(0.8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestProfile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.white,
            child: Icon(
              Icons.person,
              color: AppTheme.darkBlue,
              size: 16,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'ضيف',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('الملف الشخصي'),
              onTap: () {
                Navigator.pop(context);
                // الانتقال إلى الملف الشخصي
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('الإعدادات'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 4; // تبويب الإعدادات
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('المساعدة'),
              onTap: () {
                Navigator.pop(context);
                // عرض المساعدة
              },
            ),
            const Divider(),
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
      ),
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

  Widget _buildSidebar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    const isWebOrDesktop = kIsWeb || !kIsWeb; // Simplified check for now
    final showSidebarPermanently = isDesktop && isWebOrDesktop;

    // Updated menu items - removed students item
    final menuItems = [
      DrawerMenuItem(
        icon: AppIcons.dashboard,
        title: 'لوحة التحكم',
        index: 0,
      ),
      DrawerMenuItem(
        icon: AppIcons.courses,
        title: 'الدورات',
        index: 1,
      ),
      // Removed students menu item
      DrawerMenuItem(
        icon: AppIcons.certificates,
        title: 'الشهادات',
        index: 2, // Updated index
      ),
      DrawerMenuItem(
        icon: AppIcons.settings,
        title: 'الإعدادات',
        index: 3, // Updated index
      ),
    ];

    return SizedBox(
      width: isTablet ? 300 : 280, // Wider for tablets
      child: Container(
        color: AppTheme.darkBlue,
        child: Column(
          children: [
            // Header with user profile and stats
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: isDesktop
                    ? AppTheme.paddingLarge
                    : MediaQuery.of(context).padding.top +
                        AppTheme.paddingMedium,
                left: AppTheme.paddingLarge,
                right: AppTheme.paddingLarge,
                bottom: AppTheme.paddingLarge,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.darkBlue,
              ),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return _buildDrawerHeader(state.user);
                  }
                  return _buildGuestDrawerHeader();
                },
              ),
            ),
            Divider(
              height: 1,
              color: AppTheme.white.withOpacity(0.1),
            ),
            // Menu Items
            Expanded(
              child: Container(
                color: AppTheme.darkBlue,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.paddingMedium),
                  itemCount: menuItems.length + 1, // +1 for logout item
                  itemBuilder: (context, index) {
                    if (index == menuItems.length) {
                      // Logout item
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppTheme.paddingSmall,
                          vertical: 2,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              if (!_isTabletMode && !showSidebarPermanently) {
                                _closeSidebar(); // Close sidebar only on mobile
                              }
                              _showLogoutDialog();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.paddingMedium,
                                vertical: AppTheme.paddingMedium,
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    AppIcons.logout,
                                    color: AppTheme.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: AppTheme.paddingMedium),
                                  Text(
                                    'تسجيل الخروج',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppTheme.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final item = menuItems[index];
                    final isActive = _currentIndex == item.index;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                        vertical: 2,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            if (!_isTabletMode && !showSidebarPermanently) {
                              _closeSidebar(); // Close sidebar only on mobile
                            }
                            _navigateToTab(item.index);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.paddingMedium,
                              vertical: AppTheme.paddingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.yellow.withOpacity(0.2)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item.icon,
                                  color: isActive
                                      ? AppTheme.yellow
                                      : AppTheme.white,
                                  size: 20,
                                ),
                                const SizedBox(width: AppTheme.paddingMedium),
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isActive
                                        ? AppTheme.yellow
                                        : AppTheme.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (context) => const NotificationsPanel(),
    );
  }

  // Gesture handlers for swipe functionality
  DragStartDetails? _dragStartDetails;

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartDetails = details;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Only handle swipe from right edge of screen (to open sidebar)
    if (_dragStartDetails != null) {
      final dragStart = _dragStartDetails!.globalPosition.dx;
      final screenWidth = MediaQuery.of(context).size.width;

      // If drag started near the right edge (within 50 pixels) and is moving left
      if (dragStart > screenWidth - 50 && details.delta.dx < 0) {
        // Update sidebar position based on drag
        final progress = (-details.delta.dx) / screenWidth;
        _sidebarController.value =
            (_sidebarController.value + progress).clamp(0.0, 1.0);
      }
      // If sidebar is open and drag is moving right (to close)
      else if (_isSidebarOpen && details.delta.dx > 0) {
        final progress = (details.delta.dx) / screenWidth;
        _sidebarController.value =
            (_sidebarController.value - progress).clamp(0.0, 1.0);
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // Determine if we should open or close the sidebar based on velocity and position
    if (_sidebarController.value > 0.5 ||
        details.velocity.pixelsPerSecond.dx < -500) {
      _openSidebar();
    } else {
      _closeSidebar();
    }
    _dragStartDetails = null;
  }

  void _openSidebar() {
    setState(() {
      _isSidebarOpen = true;
    });
    _sidebarController.forward();
  }

  void _closeSidebar() {
    _sidebarController.reverse().then((_) {
      setState(() {
        _isSidebarOpen = false;
      });
    });
  }

  Widget _buildDrawerHeader(dynamic user) {
    // Get mock statistics for the user
    const courseCount = 12; // Mock data
    const studentCount = 245; // Mock data
    const certificateCount = 187; // Mock data

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.yellow,
              child: Text(
                user.name?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'مستخدم',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getUserTypeText(user.type),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Close button for the drawer
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        // Statistics cards
        Row(
          children: [
            _buildStatCard(courseCount, 'دورات'),
            const SizedBox(width: AppTheme.paddingSmall),
            _buildStatCard(studentCount, 'طلاب'),
            const SizedBox(width: AppTheme.paddingSmall),
            _buildStatCard(certificateCount, 'شهادات'),
          ],
        ),
      ],
    );
  }

  Widget _buildGuestDrawerHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.yellow,
              child: Icon(
                Icons.person,
                color: AppTheme.darkBlue,
                size: 30,
              ),
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ضيف',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  Text(
                    'زائر',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme
                          .darkGray, // Fixed: using darkGray instead of white70
                    ),
                  ),
                ],
              ),
            ),
            // Close button for the drawer
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        // Statistics cards
        Row(
          children: [
            _buildStatCard(0, 'دورات'),
            const SizedBox(width: AppTheme.paddingSmall),
            _buildStatCard(0, 'طلاب'),
            const SizedBox(width: AppTheme.paddingSmall),
            _buildStatCard(0, 'شهادات'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(int count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        decoration: BoxDecoration(
          color: AppTheme.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar ثابت للشاشات الكبيرة
        Container(
          width: 280,
          decoration: const BoxDecoration(
            color: AppTheme.darkBlue,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 0),
              ),
            ],
          ),
          child: _buildSidebar(),
        ),
        // المحتوى الرئيسي
        Expanded(
          child: _buildMainContent(),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;
    const isWebOrDesktop = kIsWeb || !kIsWeb; // Simplified check for now
    final showSidebarPermanently = isDesktop && isWebOrDesktop;

    if (showSidebarPermanently && screenWidth >= 768) {
      return Row(
        children: [
          // Permanent sidebar for web/desktop
          SizedBox(
            width: 280,
            child: _buildSidebar(),
          ),
          // Main content area
          Expanded(
            child: _buildScreenContent(),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: _buildScreenContent(),
        ),
      ],
    );
  }

  Widget _buildScreenContent() {
    switch (_currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const CourseScreen();
      // Removed case 2 for StudentScreen
      case 2: // Updated index for CertificateScreen
        return const CertificateScreen();
      case 3: // Updated index for SettingsScreen
        return const SettingsScreen();
      default:
        return const DashboardScreen();
    }
  }

  // Updated bottom navigation - removed students item
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        _navigateToTab(index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.yellow,
      unselectedItemColor: AppTheme.darkGray,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(AppIcons.dashboard),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.courses),
          label: 'الدورات',
        ),
        // Removed students item
        BottomNavigationBarItem(
          icon: Icon(AppIcons.certificates),
          label: 'الشهادات',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.settings),
          label: 'الإعدادات',
        ),
      ],
    );
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    // تحديث NavigationBloc
    context.read<NavigationBloc>().add(NavigationTabChanged(index: index));
  }

  void showLogoutDialog() async {
    final confirmed = await NavigationHelper.showConfirmDialog(
      context,
      title: 'تسجيل الخروج',
      message: 'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
      confirmText: 'تسجيل الخروج',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      context.read<AuthBloc>().add(AuthLogoutRequested());
    }
  }

  String _getUserTypeText(UserType type) {
    switch (type) {
      case UserType.admin:
        return 'مدير';
      case UserType.provider:
        return 'مقدم خدمة';
      case UserType.student:
        return 'طالب';
    }
  }
}

class DrawerMenuItem {
  final IconData icon;
  final String title;
  final int index;

  DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.index,
  });
}
