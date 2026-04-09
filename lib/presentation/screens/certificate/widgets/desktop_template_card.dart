import 'package:flutter/material.dart';
import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/core/utils/app_icons.dart';
import 'package:course_provider/data/models/certificate/certificate_template.dart';

class DesktopTemplateCard extends StatelessWidget {
  final CertificateTemplate template;
  final bool isTablet;
  final VoidCallback onEdit;
  final VoidCallback onIssue;
  final VoidCallback onToggleAutoIssue;

  const DesktopTemplateCard({
    super.key,
    required this.template,
    required this.isTablet,
    required this.onEdit,
    required this.onIssue,
    required this.onToggleAutoIssue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isTablet ? 100 : 120,
          height: isTablet ? 70 : 80,
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: AppTheme.mediumGray),
          ),
          child: const Icon(
            AppIcons.certificates,
            size: 40,
            color: AppTheme.darkGray,
          ),
        ),
        SizedBox(
            width: isTablet ? AppTheme.paddingMedium : AppTheme.paddingLarge),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                template.name,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                template.type == 'classic' ? 'قالب كلاسيكي' : 'قالب حديث',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    template.isAutoIssueEnabled
                        ? AppIcons.checkCircle
                        : AppIcons.clock,
                    size: 16,
                    color: template.isAutoIssueEnabled
                        ? AppTheme.green
                        : AppTheme.yellow,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    template.isAutoIssueEnabled
                        ? 'الإصدار التلقائي مفعل'
                        : 'الإصدار التلقائي معطل',
                    style: TextStyle(
                      fontSize: 12,
                      color: template.isAutoIssueEnabled
                          ? AppTheme.green
                          : AppTheme.yellow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: [
            ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(AppIcons.edit, size: 16, color: AppTheme.yellow),
              label: const Text('تحرير'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBlue,
                foregroundColor: AppTheme.white,
                minimumSize: const Size(100, 36),
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            ElevatedButton.icon(
              onPressed: onIssue,
              icon: const Icon(AppIcons.certificates,
                  size: 16, color: AppTheme.yellow),
              label: const Text('إصدار'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBlue,
                foregroundColor: AppTheme.white,
                minimumSize: const Size(100, 36),
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            ElevatedButton.icon(
              onPressed: onToggleAutoIssue,
              icon: Icon(
                template.isAutoIssueEnabled
                    ? AppIcons.toggleOn
                    : AppIcons.toggleOff,
                size: 16,
                color: AppTheme.yellow,
              ),
              label: Text(template.isAutoIssueEnabled ? 'تعطيل' : 'تفعيل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBlue,
                foregroundColor: AppTheme.white,
                minimumSize: const Size(100, 36),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
