import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/index.dart';

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? textColor;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.yellow.withOpacity(0.2),
                        AppTheme.blue.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: isMobile ? 20 : 22,
                    color: AppTheme.darkBlue,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.w600,
                          color: textColor ?? AppTheme.darkBlue,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 13,
                            color: AppTheme.darkGray.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: isMobile ? 16 : 18,
                    color: AppTheme.darkGray.withOpacity(0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserProfileWidget extends StatelessWidget {
  final User user;

  const UserProfileWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(
          isMobile ? AppTheme.paddingMedium : AppTheme.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkBlue,
            AppTheme.darkBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isMobile ? 30 : 35,
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: isMobile ? 30 : 35,
                    color: AppTheme.white,
                  )
                : null,
          ),
          SizedBox(
              width: isMobile ? AppTheme.paddingSmall : AppTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: AppTheme.white.withOpacity(0.8),
                  ),
                ),
                if (user.phone != null) ...[
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    user.phone!,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: AppTheme.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.yellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getUserTypeText(user.userType),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getUserTypeText(UserType type) {
    return 'مقدم خدمة';
  }
}

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
          isMobile ? AppTheme.paddingMedium : AppTheme.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkBlue,
            AppTheme.darkBlue.withOpacity(0.9),
          ],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: isMobile ? 40 : 50,
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: isMobile ? 40 : 50,
                    color: AppTheme.white,
                  )
                : null,
          ),
          SizedBox(
              height:
                  isMobile ? AppTheme.paddingSmall : AppTheme.paddingMedium),
          Text(
            user.name,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            user.email,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppTheme.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height:
                  isMobile ? AppTheme.paddingSmall : AppTheme.paddingMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.yellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getUserTypeText(user.userType),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getUserTypeText(UserType type) {
    return 'مقدم خدمة تعليمية';
  }
}

class AboutAppHeader extends StatelessWidget {
  const AboutAppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
          isMobile ? AppTheme.paddingMedium : AppTheme.paddingLarge),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkBlue,
            AppTheme.blue,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.school,
              size: isMobile ? 30 : 40,
              color: AppTheme.darkBlue,
            ),
          ),
          SizedBox(
              height:
                  isMobile ? AppTheme.paddingSmall : AppTheme.paddingMedium),
          Text(
            'منصة وصلة التعليمية',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            'الإصدار 1.0.0',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppTheme.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
