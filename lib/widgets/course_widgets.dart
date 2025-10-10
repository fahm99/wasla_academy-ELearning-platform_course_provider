import 'package:flutter/material.dart';
import '../theme/Theme.dart';
import '../models/index.dart';

class CourseTableWidget extends StatelessWidget {
  final List<Course> courses;
  final Function(Course) onEdit;
  final Function(Course) onView;
  final Function(Course) onDelete;

  const CourseTableWidget({
    super.key,
    required this.courses,
    required this.onEdit,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.mediumGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _getTableWidth(context),
          child: Column(
            children: [
              _buildTableHeader(),
              Expanded(
                child: ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return _buildTableRow(course, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getTableWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // تحديد عرض الجدول بناءً على حجم الشاشة
    if (screenWidth < 600) {
      return 800; // عرض ثابت للشاشات الصغيرة
    } else if (screenWidth < 1200) {
      return screenWidth * 1.2; // عرض أكبر قليلاً من الشاشة للشاشات المتوسطة
    } else {
      return screenWidth; // عرض الشاشة للشاشات الكبيرة
    }
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 250,
            child: Text(
              'الكورس',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              'التصنيف',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'المستوى',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              'الطلاب',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              'السعر',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'الحالة',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              'الإجراءات',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Course course, int index) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
            index % 2 == 0 ? Colors.white : AppTheme.lightGray.withOpacity(0.3),
        border: const Border(
          bottom: BorderSide(color: AppTheme.mediumGray),
        ),
      ),
      child: Row(
        children: [
          // Course Info
          SizedBox(
            width: 250,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    course.imageUrl ?? 'https://via.placeholder.com/60x60',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: AppTheme.mediumGray,
                        child: const Icon(Icons.school,
                            color: AppTheme.darkGray, size: 20),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${(course.duration / 60).ceil()} ساعات',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Category
          SizedBox(
            width: 100,
            child: Text(
              _getCategoryDisplayName(course.category),
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Level
          SizedBox(
            width: 80,
            child: Text(
              _getLevelDisplayName(course.level),
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Students Count
          SizedBox(
            width: 70,
            child: Text(
              '${course.studentsCount}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          // Price
          SizedBox(
            width: 100,
            child: course.isFree
                ? const Text(
                    'مجاني',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.green,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Text(
                    '${course.price.toInt()} ريال',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          // Status
          SizedBox(
            width: 80,
            child: StatusBadge(status: course.status),
          ),
          // Actions
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Expanded(
                  child: ActionButton(
                    text: 'تعديل',
                    backgroundColor: AppTheme.yellow,
                    textColor: AppTheme.darkBlue,
                    onPressed: () => onEdit(course),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ActionButton(
                    text: 'عرض',
                    backgroundColor: AppTheme.darkBlue,
                    textColor: Colors.white,
                    onPressed: () => onView(course),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'tech':
        return 'تقنية';
      case 'language':
        return 'لغات';
      case 'development':
        return 'تنمية بشرية';
      case 'business':
        return 'أعمال';
      default:
        return 'غير محدد';
    }
  }

  String _getLevelDisplayName(CourseLevel level) {
    switch (level) {
      case CourseLevel.beginner:
        return 'مبتدئ';
      case CourseLevel.intermediate:
        return 'متوسط';
      case CourseLevel.advanced:
        return 'متقدم';
      default:
        return 'غير محدد';
    }
  }
}

class StatusBadge extends StatelessWidget {
  final CourseStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case CourseStatus.published:
        backgroundColor = AppTheme.green.withOpacity(0.1);
        textColor = AppTheme.green;
        text = 'منشور';
        break;
      case CourseStatus.draft:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        text = 'مسودة';
        break;
      case CourseStatus.pending:
        backgroundColor = AppTheme.blue.withOpacity(0.1);
        textColor = AppTheme.blue;
        text = 'قيد المراجعة';
        break;
      case CourseStatus.rejected:
        backgroundColor = AppTheme.red.withOpacity(0.1);
        textColor = AppTheme.red;
        text = 'مرفوض';
        break;
      case CourseStatus.archived:
        backgroundColor = AppTheme.darkGray.withOpacity(0.1);
        textColor = AppTheme.darkGray;
        text = 'مؤرشف';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        minimumSize: const Size(0, 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.mediumGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class CourseSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CourseSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'بحث في الكورسات...',
          prefixIcon: Icon(Icons.search, color: AppTheme.darkGray),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
