import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../repository/main_repository.dart';
import '../theme/Theme.dart';
import '../widgets/index.dart';
import '../data/Mockdata.dart';
import '../utils/app_icons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsCards(),
              const SizedBox(height: AppTheme.paddingLarge),
              _buildQuickActions(),
              const SizedBox(height: AppTheme.paddingLarge),
              _buildNotifications(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return FutureBuilder<Map<String, int>>(
      future: context.read<MainRepository>().getBasicStatistics(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final stats = snapshot.data!;
          return _buildUnifiedStatisticsCard(stats);
        } else {
          return _buildUnifiedStatisticsCardSkeleton();
        }
      },
    );
  }

  Widget _buildUnifiedStatisticsCard(Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.darkBlue,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نظرة عامة على الإحصائيات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  title: 'إجمالي الدورات',
                  value: stats['totalCourses'].toString(),
                  icon: AppIcons.courses,
                  trend: '+12%',
                ),
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Expanded(
                child: _buildStatItem(
                  title: 'الدورات المنشورة',
                  value: stats['publishedCourses'].toString(),
                  icon: AppIcons.publish,
                  trend: '+8%',
                ),
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Expanded(
                child: _buildStatItem(
                  title: 'إجمالي الطلاب',
                  value: stats['totalStudents'].toString(),
                  icon: AppIcons.students,
                  trend: '+15%',
                ),
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Expanded(
                child: _buildStatItem(
                  title: 'الشهادات الصادرة',
                  value: stats['totalCertificates'].toString(),
                  icon: AppIcons.star,
                  trend: '+5%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingSmall,
        vertical: AppTheme.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(
          color: AppTheme.yellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.yellow,
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8,
              color: AppTheme.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: AppTheme.yellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              trend,
              style: const TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: AppTheme.yellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedStatisticsCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.darkBlue,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 150,
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Expanded(child: _buildStatItemSkeleton()),
              const SizedBox(width: AppTheme.paddingSmall),
              Expanded(child: _buildStatItemSkeleton()),
              const SizedBox(width: AppTheme.paddingSmall),
              Expanded(child: _buildStatItemSkeleton()),
              const SizedBox(width: AppTheme.paddingSmall),
              Expanded(child: _buildStatItemSkeleton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingSmall,
        vertical: AppTheme.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(
          color: AppTheme.yellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 14,
            width: 25,
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 8,
            width: 40,
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 7,
            width: 20,
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
          child: Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkBlue,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
            children: [
              _buildQuickActionCard(
                icon: AppIcons.add,
                title: 'إضافة دورة',
                onTap: () => _navigateToCourseCreation(),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              _buildQuickActionCard(
                icon: AppIcons.userAdd,
                title: 'إضافة طالب',
                onTap: () => _navigateToStudentCreation(),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              _buildQuickActionCard(
                icon: AppIcons.certificates,
                title: 'إصدار شهادة',
                onTap: () => _navigateToCertificateCreation(),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              _buildQuickActionCard(
                icon: AppIcons.download,
                title: 'تصدير التقارير',
                onTap: () => _exportReports(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: AppTheme.darkBlue.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkBlue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.darkBlue,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: AppTheme.yellow,
                size: 24,
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifications() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(
          color: AppTheme.darkBlue.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkBlue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      AppIcons.bell,
                      color: AppTheme.yellow,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  const Text(
                    'الإشعارات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showAllNotifications(),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.darkBlue,
                ),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: MockData.mockNotifications.take(3).length,
            separatorBuilder: (context, index) => Divider(
              color: AppTheme.darkBlue.withOpacity(0.1),
            ),
            itemBuilder: (context, index) {
              final notification = MockData.mockNotifications[index];
              return _buildNotificationItem(
                title: notification['title'],
                message: notification['message'],
                timestamp: notification['timestamp'] ?? DateTime.now(),
                isRead: notification['isRead'] ?? false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required DateTime timestamp,
    required bool isRead,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color:
                  isRead ? AppTheme.darkBlue.withOpacity(0.3) : AppTheme.yellow,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkBlue.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.darkBlue.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  void _navigateToCourseCreation() {
    // For now, we'll navigate to the courses tab
    context.push('/main?tab=1');
  }

  void _navigateToStudentCreation() {
    context.push('/main?tab=2');
  }

  void _navigateToCertificateCreation() {
    context.push('/main?tab=3');
  }

  void _exportReports() {
    // تم إزالة تصدير التقارير المفصلة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إزالة ميزة تصدير التقارير المفصلة')),
    );
  }

  void _showAllNotifications() {
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
}
