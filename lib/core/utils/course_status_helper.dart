import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../data/models/course.dart';

/// مساعد لإدارة حالات الكورسات
class CourseStatusHelper {
  /// الحصول على نص الحالة باللغة العربية
  static String getStatusText(CourseStatus status) {
    switch (status) {
      case CourseStatus.draft:
        return 'مسودة';
      case CourseStatus.pendingReview:
        return 'قيد المراجعة';
      case CourseStatus.published:
        return 'منشور';
      case CourseStatus.archived:
        return 'مؤرشف';
    }
  }

  /// الحصول على لون الحالة
  static Color getStatusColor(CourseStatus status) {
    switch (status) {
      case CourseStatus.draft:
        return AppTheme.darkGray;
      case CourseStatus.pendingReview:
        return AppTheme.yellow;
      case CourseStatus.published:
        return AppTheme.green;
      case CourseStatus.archived:
        return AppTheme.red;
    }
  }

  /// الحصول على أيقونة الحالة
  static IconData getStatusIcon(CourseStatus status) {
    switch (status) {
      case CourseStatus.draft:
        return Icons.edit;
      case CourseStatus.pendingReview:
        return Icons.hourglass_empty;
      case CourseStatus.published:
        return Icons.check_circle;
      case CourseStatus.archived:
        return Icons.archive;
    }
  }

  /// الحصول على widget للحالة
  static Widget getStatusWidget(CourseStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: getStatusColor(status),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getStatusIcon(status),
            size: 14,
            color: getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            getStatusText(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  /// التحقق من إمكانية النشر
  static bool canPublish(Course course) {
    return course.status == CourseStatus.draft &&
        course.title.isNotEmpty &&
        course.description.isNotEmpty;
  }

  /// التحقق من إمكانية الأرشفة
  static bool canArchive(Course course) {
    return course.status != CourseStatus.archived;
  }

  /// التحقق من إمكانية التعديل
  static bool canEdit(Course course) {
    return course.status != CourseStatus.archived;
  }

  /// التحقق من إمكانية الحذف
  static bool canDelete(Course course) {
    return course.studentsCount == 0;
  }

  /// الحصول على الحالة التالية المتاحة
  static List<CourseStatus> getAvailableTransitions(
      CourseStatus currentStatus) {
    switch (currentStatus) {
      case CourseStatus.draft:
        return [CourseStatus.published, CourseStatus.archived];
      case CourseStatus.pendingReview:
        return [CourseStatus.published, CourseStatus.draft];
      case CourseStatus.published:
        return [CourseStatus.draft, CourseStatus.archived];
      case CourseStatus.archived:
        return [CourseStatus.draft];
    }
  }

  /// الحصول على رسالة التأكيد لتغيير الحالة
  static String getConfirmationMessage(CourseStatus from, CourseStatus to) {
    switch (to) {
      case CourseStatus.published:
        return 'هل أنت متأكد من نشر هذا الكورس؟ سيصبح متاحاً للطلاب.';
      case CourseStatus.draft:
        return 'هل أنت متأكد من إلغاء نشر هذا الكورس؟ لن يعود متاحاً للطلاب الجدد.';
      case CourseStatus.archived:
        return 'هل أنت متأكد من أرشفة هذا الكورس؟ سيتم إخفاؤه من جميع القوائم.';
      case CourseStatus.pendingReview:
        return 'هل أنت متأكد من إرسال هذا الكورس للمراجعة؟';
    }
  }

  /// الحصول على نص المستوى
  static String getLevelText(CourseLevel level) {
    switch (level) {
      case CourseLevel.beginner:
        return 'مبتدئ';
      case CourseLevel.intermediate:
        return 'متوسط';
      case CourseLevel.advanced:
        return 'متقدم';
    }
  }

  /// الحصول على لون المستوى
  static Color getLevelColor(CourseLevel level) {
    switch (level) {
      case CourseLevel.beginner:
        return AppTheme.green;
      case CourseLevel.intermediate:
        return AppTheme.yellow;
      case CourseLevel.advanced:
        return AppTheme.red;
    }
  }

  /// الحصول على widget للمستوى
  static Widget getLevelWidget(CourseLevel level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getLevelColor(level).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: getLevelColor(level),
          width: 1,
        ),
      ),
      child: Text(
        getLevelText(level),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: getLevelColor(level),
        ),
      ),
    );
  }

  /// تنسيق السعر
  static String formatPrice(double price, {String currency = 'ريال'}) {
    if (price == 0) {
      return 'مجاني';
    }
    return '${price.toStringAsFixed(0)} $currency';
  }

  /// تنسيق المدة
  static String formatDuration(int? hours) {
    if (hours == null || hours == 0) {
      return 'غير محدد';
    }
    if (hours == 1) {
      return 'ساعة واحدة';
    } else if (hours == 2) {
      return 'ساعتان';
    } else if (hours < 11) {
      return '$hours ساعات';
    } else {
      return '$hours ساعة';
    }
  }

  /// تنسيق عدد الطلاب
  static String formatStudentsCount(int count) {
    if (count == 0) {
      return 'لا يوجد طلاب';
    } else if (count == 1) {
      return 'طالب واحد';
    } else if (count == 2) {
      return 'طالبان';
    } else if (count < 11) {
      return '$count طلاب';
    } else {
      return '$count طالب';
    }
  }

  /// تنسيق التقييم
  static String formatRating(double rating) {
    if (rating == 0) {
      return 'لا يوجد تقييم';
    }
    return rating.toStringAsFixed(1);
  }
}
