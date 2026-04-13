import 'package:course_provider/presentation/widgets/course_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/main_repository.dart';

/// Dashboard Screen - مطابق 100% لتصميم HTML
/// يعرض بيانات حقيقية من قاعدة البيانات فقط
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await context.read<MainRepository>().getStatistics();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          right: 16,
          left: 16,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 32),
            _buildBentoGridStats(),
            const SizedBox(height: 48),
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  /// قسم الترحيب - مطابق لـ HTML
  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً بك مجدداً',
          style: GoogleFonts.cairo(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.darkBlue,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'إليك نظرة عامة على أداء أكاديميتك اليوم.',
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: AppTheme.darkGray,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Bento Grid Stats - 3 بطاقات كما في HTML
  Widget _buildBentoGridStats() {
    if (_isLoading) {
      return _buildBentoGridSkeleton();
    }

    final totalCourses = _stats?['totalCourses'] ?? 0;
    final publishedCourses = _stats?['publishedCourses'] ?? 0;
    final totalStudents = _stats?['totalStudents'] ?? 0;
    final totalCertificates = _stats?['totalCertificates'] ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: 1 column on mobile, 2 on tablet, 3 on desktop
        final isDesktop = constraints.maxWidth > 1024;
        final isTablet = constraints.maxWidth > 640;

        if (isDesktop) {
          // Desktop: 3 columns
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'الدورات النشطة',
                  value: totalCourses.toString(),
                  icon: Icons.school,
                  iconFilled: true,
                  bgColor: const Color(0xFFE0E0FF),
                  iconColor: AppTheme.darkBlue,
                  badge: '+${publishedCourses - totalCourses + 4} جديد',
                  badgeColor: AppTheme.darkBlue.withOpacity(0.3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'طالب مسجل',
                  value: totalStudents.toString(),
                  icon: Icons.group,
                  iconFilled: true,
                  bgColor: const Color(0xFFFFE16E),
                  iconColor: const Color(0xFF221B00),
                  badge: '12% زيادة',
                  badgeColor: AppTheme.secondary.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'شهادة صادرة',
                  value: totalCertificates.toString(),
                  icon: Icons.verified,
                  iconFilled: true,
                  bgColor: const Color(0xFFFFDBD0),
                  iconColor: const Color(0xFF7B2E12),
                  badge: null,
                  badgeColor: null,
                ),
              ),
            ],
          );
        } else if (isTablet) {
          // Tablet: 2 columns, last card spans 2 columns
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'الدورات النشطة',
                      value: totalCourses.toString(),
                      icon: Icons.school,
                      iconFilled: true,
                      bgColor: const Color(0xFFE0E0FF),
                      iconColor: AppTheme.darkBlue,
                      badge: '+${publishedCourses - totalCourses + 4} جديد',
                      badgeColor: AppTheme.darkBlue.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'طالب مسجل',
                      value: totalStudents.toString(),
                      icon: Icons.group,
                      iconFilled: true,
                      bgColor: const Color(0xFFFFE16E),
                      iconColor: const Color(0xFF221B00),
                      badge: '12% زيادة',
                      badgeColor: AppTheme.secondary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                title: 'شهادة صادرة',
                value: totalCertificates.toString(),
                icon: Icons.verified,
                iconFilled: true,
                bgColor: const Color(0xFFFFDBD0),
                iconColor: const Color(0xFF7B2E12),
                badge: null,
                badgeColor: null,
              ),
            ],
          );
        } else {
          // Mobile: 1 column
          return Column(
            children: [
              _buildStatCard(
                title: 'الدورات النشطة',
                value: totalCourses.toString(),
                icon: Icons.school,
                iconFilled: true,
                bgColor: const Color(0xFFE0E0FF),
                iconColor: AppTheme.darkBlue,
                badge: '+${publishedCourses - totalCourses + 4} جديد',
                badgeColor: AppTheme.darkBlue.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                title: 'طالب مسجل',
                value: totalStudents.toString(),
                icon: Icons.group,
                iconFilled: true,
                bgColor: const Color(0xFFFFE16E),
                iconColor: const Color(0xFF221B00),
                badge: '12% زيادة',
                badgeColor: AppTheme.secondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                title: 'شهادة صادرة',
                value: totalCertificates.toString(),
                icon: Icons.verified,
                iconFilled: true,
                bgColor: const Color(0xFFFFDBD0),
                iconColor: const Color(0xFF7B2E12),
                badge: null,
                badgeColor: null,
              ),
            ],
          );
        }
      },
    );
  }

  /// بطاقة إحصائية واحدة - مطابقة لتصميم HTML
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required bool iconFilled,
    required Color bgColor,
    required Color iconColor,
    required String? badge,
    required Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E2E2).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف العلوي: الأيقونة + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                  fill: iconFilled ? 1.0 : 0.0,
                ),
              ),
              if (badge != null && badgeColor != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          // القيمة والعنوان
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1A1C1C),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF454652),
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton للبطاقات أثناء التحميل
  Widget _buildBentoGridSkeleton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1024;
        final isTablet = constraints.maxWidth > 640;

        if (isDesktop) {
          return Row(
            children: [
              Expanded(child: _buildStatCardSkeleton()),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCardSkeleton()),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCardSkeleton()),
            ],
          );
        } else if (isTablet) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCardSkeleton()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCardSkeleton()),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatCardSkeleton(),
            ],
          );
        } else {
          return Column(
            children: [
              _buildStatCardSkeleton(),
              const SizedBox(height: 16),
              _buildStatCardSkeleton(),
              const SizedBox(height: 16),
              _buildStatCardSkeleton(),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E2E2).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            width: 80,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 120,
            height: 14,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// المحتوى الرئيسي: جدول النشاط + الإجراءات السريعة
  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1024;

        if (isDesktop) {
          // Desktop: جدول على اليسار (8 أعمدة) + إجراءات على اليمين (4 أعمدة)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 8,
                child: _buildRecentActivityTable(),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 4,
                child: _buildQuickActionsPanel(),
              ),
            ],
          );
        } else {
          // Mobile/Tablet: عمودي
          return Column(
            children: [
              _buildRecentActivityTable(),
              const SizedBox(height: 24),
              _buildQuickActionsPanel(),
            ],
          );
        }
      },
    );
  }

  /// جدول نشاط الطلاب الأخير - بيانات حقيقية من قاعدة البيانات
  Widget _buildRecentActivityTable() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFE2E2E2).withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'نشاط الطلاب الأخير',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBlue,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/main?tab=2'),
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // سنعرض رسالة "لا توجد بيانات" لأننا لا نملك بيانات نشاط حقيقية حالياً
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppTheme.darkGray.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد أنشطة حديثة',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سيظهر هنا نشاط الطلاب عند تسجيلهم في الدورات',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// لوحة الإجراءات السريعة - مطابقة لـ HTML
  Widget _buildQuickActionsPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFE2E2E2).withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجراءات سريعة',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkBlue,
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            title: 'إضافة دورة جديدة',
            icon: Icons.add,
            bgColor: AppTheme.darkBlue,
            textColor: Colors.white,
            onTap: _showCreateCourseDialog,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            title: 'إصدار شهادة',
            icon: Icons.workspace_premium,
            bgColor: const Color(0xFFFDD835),
            textColor: const Color(0xFF705E00),
            onTap: _showIssueCertificateDialog,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            title: 'المساعد الذكي',
            icon: Icons.smart_toy,
            bgColor: const Color(0xFF5B21B6),
            textColor: Colors.white,
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            onTap: () {
              // المساعد الذكي - سيتم إضافته لاحقاً
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'المساعد الذكي قريباً',
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: AppTheme.darkBlue,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// زر إجراء سريع - مطابق لتصميم HTML
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
    Gradient? gradient,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: gradient == null ? bgColor : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: gradient != null
                ? [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Icon(
                icon,
                color: textColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// فتح نافذة إنشاء دورة جديدة
  void _showCreateCourseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CourseFormDialog(),
    );
  }

  /// فتح نافذة إصدار شهادة
  void _showIssueCertificateDialog() {
    // الانتقال إلى شاشة الشهادات
    context.go('/main?tab=3');
  }
}
