import 'package:flutter/material.dart';
import '../theme/Theme.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final buttonColor = color ?? AppTheme.darkBlue;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: Container(
          padding: EdgeInsets.all(
              isMobile ? AppTheme.paddingMedium : AppTheme.paddingLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                buttonColor,
                buttonColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isMobile ? 30 : 40,
                color: AppTheme.white,
              ),
              SizedBox(
                  height: isMobile
                      ? AppTheme.paddingSmall
                      : AppTheme.paddingMedium),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    color: AppTheme.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.icon,
    this.iconColor,
    this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Card(
      elevation: isRead ? 1 : 2,
      color: isRead ? AppTheme.white : AppTheme.lightGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: InkWell(
        onTap: () {
          if (!isRead && onMarkAsRead != null) {
            onMarkAsRead!();
          }
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: EdgeInsets.all(
              isMobile ? AppTheme.paddingMedium : AppTheme.paddingLarge),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.blue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon ?? Icons.notifications,
                  size: isMobile ? 16 : 20,
                  color: iconColor ?? AppTheme.blue,
                ),
              ),
              SizedBox(
                  width: isMobile
                      ? AppTheme.paddingSmall
                      : AppTheme.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight:
                                  isRead ? FontWeight.w500 : FontWeight.bold,
                              color: AppTheme.darkBlue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 4 : 8),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: AppTheme.darkGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 4 : 8),
                    Text(
                      _formatTimestamp(timestamp),
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: AppTheme.darkGray.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

class NotificationsPanel extends StatelessWidget {
  const NotificationsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // بيانات وهمية للإشعارات
    final notifications = [
      {
        'title': 'طالب جديد',
        'message': 'تم تسجيل طالب جديد في كورس البرمجة',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'isRead': false,
        'icon': Icons.person_add,
        'iconColor': AppTheme.green,
      },
      {
        'title': 'تقييم جديد',
        'message': 'حصلت على تقييم 5 نجوم من أحمد محمد',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'isRead': false,
        'icon': Icons.star,
        'iconColor': AppTheme.yellow,
      },
      {
        'title': 'دفعة جديدة',
        'message': 'تم استلام دفعة بقيمة 500 ريال',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': true,
        'icon': Icons.payment,
        'iconColor': AppTheme.blue,
      },
    ];

    return SizedBox(
      width: isMobile ? double.infinity : 400,
      height: isMobile ? MediaQuery.of(context).size.height * 0.7 : 500,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(
                isMobile ? AppTheme.paddingMedium : AppTheme.paddingLarge),
            decoration: const BoxDecoration(
              color: AppTheme.darkBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadiusLarge),
                topRight: Radius.circular(AppTheme.borderRadiusLarge),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإشعارات',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Mark all as read
                  },
                  child: const Text(
                    'تحديد الكل كمقروء',
                    style: TextStyle(
                      color: AppTheme.yellow,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(
                  isMobile ? AppTheme.paddingSmall : AppTheme.paddingMedium),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
                  child: NotificationItem(
                    title: notification['title'] as String,
                    message: notification['message'] as String,
                    timestamp: notification['timestamp'] as DateTime,
                    isRead: notification['isRead'] as bool,
                    icon: notification['icon'] as IconData,
                    iconColor: notification['iconColor'] as Color,
                    onTap: () {
                      // Handle notification tap
                    },
                    onMarkAsRead: () {
                      // Handle mark as read
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
