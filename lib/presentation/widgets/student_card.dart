import 'package:flutter/material.dart';
import '../../data/models/index.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_icons.dart';

class StudentCard extends StatelessWidget {
  final Enrollment enrollment;
  final String? studentName;
  final String? studentEmail;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onEnroll;
  final VoidCallback? onMessage;

  const StudentCard({
    super.key,
    required this.enrollment,
    this.studentName,
    this.studentEmail,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onEnroll,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: Padding(
          padding: EdgeInsets.all(
              isMobile ? AppTheme.paddingMedium : AppTheme.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: isMobile ? 25 : 30,
                    backgroundColor: AppTheme.darkBlue.withOpacity(0.1),
                    child: Icon(
                      AppIcons.user,
                      size: isMobile ? 25 : 30,
                      color: AppTheme.darkBlue,
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
                        Text(
                          studentName ?? enrollment.studentId,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (studentEmail != null) ...[
                          SizedBox(height: isMobile ? 2 : 4),
                          Text(
                            studentEmail!,
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 12,
                              color: AppTheme.darkGray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(enrollment.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(enrollment.status),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Text(
                        '${enrollment.completionPercentage}%',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                  height: isMobile
                      ? AppTheme.paddingSmall
                      : AppTheme.paddingMedium),
              Row(
                children: [
                  const Icon(AppIcons.calendar,
                      size: 12, color: AppTheme.darkGray),
                  const SizedBox(width: 4),
                  Text(
                    'تاريخ التسجيل: ${_formatDate(enrollment.enrollmentDate)}',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: isMobile
                      ? AppTheme.paddingSmall
                      : AppTheme.paddingMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onMessage != null)
                    IconButton(
                      onPressed: onMessage,
                      icon: const Icon(AppIcons.message, size: 16),
                      tooltip: 'مراسلة',
                    ),
                  if (onEnroll != null)
                    IconButton(
                      onPressed: onEnroll,
                      icon: const Icon(AppIcons.add, size: 16),
                      tooltip: 'تسجيل في كورس',
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: AppTheme.red),
                            SizedBox(width: 8),
                            Text('حذف', style: TextStyle(color: AppTheme.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(EnrollmentStatus status) {
    switch (status) {
      case EnrollmentStatus.active:
        return 'نشط';
      case EnrollmentStatus.completed:
        return 'مكتمل';
      case EnrollmentStatus.dropped:
        return 'منسحب';
    }
  }

  Color _getStatusColor(EnrollmentStatus status) {
    switch (status) {
      case EnrollmentStatus.active:
        return AppTheme.green;
      case EnrollmentStatus.completed:
        return AppTheme.darkBlue;
      case EnrollmentStatus.dropped:
        return AppTheme.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        onEdit?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}
