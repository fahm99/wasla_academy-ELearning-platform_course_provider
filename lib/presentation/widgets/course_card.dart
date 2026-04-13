import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/index.dart';
import '../../core/utils/app_icons.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onManageContent;
  final VoidCallback? onManageExams;
  final VoidCallback onViewStudents;
  final VoidCallback onManageCertificates;
  final VoidCallback onTogglePublish;
  final VoidCallback onDelete;

  const CourseCard({
    super.key,
    required this.course,
    required this.onEdit,
    required this.onManageContent,
    this.onManageExams,
    required this.onViewStudents,
    required this.onManageCertificates,
    required this.onTogglePublish,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourseImage(),
          // Fixed the overflow by ensuring proper sizing and using Flexible
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCourseInfo(),
                const SizedBox(height: 16),
                // Show action buttons in full width for list view
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseImage() {
    // استخدام imageUrl (الذي يشير إلى coverImageUrl) أو thumbnailUrl
    final imageUrl = course.imageUrl ?? course.thumbnailUrl;

    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: AppTheme.lightGray,
      ),
      child: Stack(
        children: [
          // عرض الصورة
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      AppIcons.courses,
                      size: 60,
                      color: AppTheme.darkGray,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppTheme.darkBlue,
                    ),
                  );
                },
              ),
            )
          else
            const Center(
              child: Icon(
                AppIcons.courses,
                size: 60,
                color: AppTheme.darkGray,
              ),
            ),
          // شارة الحالة
          Positioned(
            top: 12,
            right: 12,
            child: _buildStatusBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (course.status) {
      case CourseStatus.published:
        backgroundColor = AppTheme.green;
        textColor = AppTheme.white;
        text = 'منشور';
        icon = AppIcons.active;
        break;
      case CourseStatus.draft:
        backgroundColor = AppTheme.yellow;
        textColor = AppTheme.darkBlue;
        text = 'مسودة';
        icon = AppIcons.draft;
        break;
      default:
        backgroundColor = AppTheme.darkGray;
        textColor = AppTheme.white;
        text = 'غير محدد';
        icon = AppIcons.inactive;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.title,
          style: const TextStyle(
            fontSize: 14, // Reduced font size
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6), // Reduced spacing
        Row(
          children: [
            const Icon(
              AppIcons.students,
              size: 12, // Reduced icon size
              color: AppTheme.darkGray,
            ),
            const SizedBox(width: 4),
            Text(
              '${course.studentsCount} طالب',
              style: const TextStyle(
                fontSize: 11, // Reduced font size
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2), // Reduced spacing
        Row(
          children: [
            const Icon(
              AppIcons.calendar,
              size: 12, // Reduced icon size
              color: AppTheme.darkGray,
            ),
            const SizedBox(width: 4),
            Text(
              _formatDate(course.updatedAt),
              style: const TextStyle(
                fontSize: 11, // Reduced font size
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row of buttons
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: AppIcons.edit,
                label: 'تحرير',
                color: AppTheme.darkBlue,
                textColor: AppTheme.white,
                iconColor: AppTheme.yellow,
                onPressed: onEdit,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: AppIcons.courses,
                label: 'إدارة المحتوى',
                color: AppTheme.darkBlue,
                textColor: AppTheme.white,
                iconColor: AppTheme.yellow,
                onPressed: onManageContent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Second row of buttons
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: AppIcons.quiz,
                label: 'إدارة الامتحانات',
                color: AppTheme.darkBlue,
                textColor: AppTheme.white,
                iconColor: AppTheme.yellow,
                onPressed: onManageExams ?? () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: AppIcons.students,
                label: 'عرض الطلاب',
                color: AppTheme.darkBlue,
                textColor: AppTheme.white,
                iconColor: AppTheme.yellow,
                onPressed: onViewStudents,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Third row of buttons
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: AppIcons.certificates,
                label: 'إدارة الشهادات',
                color: AppTheme.darkBlue,
                textColor: AppTheme.white,
                iconColor: AppTheme.yellow,
                onPressed: onManageCertificates,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: course.status == CourseStatus.published
                    ? AppIcons.inactive
                    : AppIcons.publish,
                label: course.status == CourseStatus.published
                    ? 'إلغاء النشر'
                    : 'نشر الكورس',
                color: course.status == CourseStatus.published
                    ? AppTheme.red
                    : AppTheme.darkBlue,
                textColor: AppTheme.white,
                iconColor: AppTheme.yellow,
                onPressed: onTogglePublish,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Fourth row with delete button
        _buildActionButton(
          icon: AppIcons.delete,
          label: 'حذف الكورس',
          color: AppTheme.red,
          textColor: AppTheme.white,
          iconColor: AppTheme.white,
          onPressed: onDelete,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(0, 40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
