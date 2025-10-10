import 'package:flutter/material.dart';
import '../theme/Theme.dart';
import '../utils/app_icons.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? trendUp;

  const StatisticCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Container(
        padding: EdgeInsets.all(
            isMobile ? AppTheme.paddingMedium : AppTheme.paddingLarge),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border(
            right: BorderSide(color: color, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 8 : 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: isMobile ? 20 : 24),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (trendUp ?? true)
                          ? AppTheme.green.withOpacity(0.1)
                          : AppTheme.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (trendUp ?? true)
                              ? AppIcons.arrowUp
                              : AppIcons.arrowDown,
                          size: 10,
                          color:
                              (trendUp ?? true) ? AppTheme.green : AppTheme.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trend!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: (trendUp ?? true)
                                ? AppTheme.green
                                : AppTheme.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(
                height:
                    isMobile ? AppTheme.paddingSmall : AppTheme.paddingMedium),
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 22 : (isTablet ? 25 : 28),
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
            SizedBox(height: isMobile ? 4 : AppTheme.paddingSmall),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticCardSkeleton extends StatelessWidget {
  const StatisticCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Container(
        padding: EdgeInsets.all(
            isMobile ? AppTheme.paddingMedium : AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: isMobile ? 40 : 48,
                  height: isMobile ? 40 : 48,
                  decoration: BoxDecoration(
                    color: AppTheme.mediumGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  width: isMobile ? 35 : 40,
                  height: isMobile ? 18 : 20,
                  decoration: BoxDecoration(
                    color: AppTheme.mediumGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            SizedBox(
                height:
                    isMobile ? AppTheme.paddingSmall : AppTheme.paddingMedium),
            Container(
              width: isMobile ? 70 : 80,
              height: isMobile ? 24 : 28,
              decoration: BoxDecoration(
                color: AppTheme.mediumGray,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: isMobile ? 4 : AppTheme.paddingSmall),
            Container(
              width: isMobile ? 100 : 120,
              height: isMobile ? 12 : 14,
              decoration: BoxDecoration(
                color: AppTheme.mediumGray,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
