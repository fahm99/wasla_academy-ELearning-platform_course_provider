import 'package:flutter/material.dart';
import '../theme/Theme.dart';
import '../models/index.dart';
import '../utils/app_icons.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onEnroll;
  final VoidCallback? onMessage;
  final VoidCallback? onActivate;
  final VoidCallback? onDeactivate;
  final VoidCallback? onSuspend;
  final VoidCallback? onEnrollToCourse;
  final VoidCallback? onViewCertificates;

  const StudentCard({
    super.key,
    required this.student,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onEnroll,
    this.onMessage,
    this.onActivate,
    this.onDeactivate,
    this.onSuspend,
    this.onEnrollToCourse,
    this.onViewCertificates,
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
                    backgroundImage: student.avatar != null
                        ? NetworkImage(student.avatar!)
                        : null,
                    child: student.avatar == null
                        ? Icon(
                            AppIcons.user,
                            size: isMobile ? 25 : 30,
                            color: AppTheme.darkGray,
                          )
                        : null,
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
                          student.name,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        Text(
                          student.email,
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            color: AppTheme.darkGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (student.phone != null) ...[
                          SizedBox(height: isMobile ? 2 : 4),
                          Text(
                            student.phone!,
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 12,
                              color: AppTheme.darkGray,
                            ),
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
                          color: _getStatusColor(student.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(student.status),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Text(
                        '${student.enrolledCourses.length} كورس',
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
                  const Icon(
                    AppIcons.calendar,
                    size: 12,
                    color: AppTheme.darkGray,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'تاريخ التسجيل: ${_formatDate(student.enrollmentDate)}',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
              if (student.certificateIds.isNotEmpty) ...[
                SizedBox(height: isMobile ? 4 : 8),
                Row(
                  children: [
                    const Icon(
                      AppIcons.star,
                      size: 12,
                      color: AppTheme.yellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${student.certificateIds.length} شهادة',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ],
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

  String _getStatusText(StudentStatus status) {
    switch (status) {
      case StudentStatus.active:
        return 'نشط';
      case StudentStatus.inactive:
        return 'غير نشط';
      case StudentStatus.suspended:
        return 'موقوف';
    }
  }

  Color _getStatusColor(StudentStatus status) {
    switch (status) {
      case StudentStatus.active:
        return AppTheme.green;
      case StudentStatus.inactive:
        return AppTheme.darkGray;
      case StudentStatus.suspended:
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
