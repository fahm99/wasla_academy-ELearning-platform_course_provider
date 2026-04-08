import 'package:flutter/material.dart';
import '../../data/models/index.dart';

class SortOption {
  final String value;
  final String label;

  const SortOption(this.value, this.label);
}

class SortDialog extends StatefulWidget {
  final List<SortOption> options;
  final Function(String sortBy, bool ascending) onSort;

  const SortDialog({
    super.key,
    required this.options,
    required this.onSort,
  });

  @override
  State<SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {
  String? selectedOption;
  bool ascending = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ترتيب حسب'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.options.map((option) => RadioListTile<String>(
                title: Text(option.label),
                value: option.value,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
              )),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('تصاعدي'),
                  value: true,
                  groupValue: ascending,
                  onChanged: (value) {
                    setState(() {
                      ascending = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('تنازلي'),
                  value: false,
                  groupValue: ascending,
                  onChanged: (value) {
                    setState(() {
                      ascending = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: selectedOption != null
              ? () {
                  Navigator.of(context).pop();
                  widget.onSort(selectedOption!, ascending);
                }
              : null,
          child: const Text('تطبيق'),
        ),
      ],
    );
  }
}

class ExportDialog extends StatelessWidget {
  final String title;
  final Function(String format) onExport;

  const ExportDialog({
    super.key,
    required this.title,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تصدير $title'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Excel (.xlsx)'),
            onTap: () {
              Navigator.of(context).pop();
              onExport('xlsx');
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('CSV (.csv)'),
            onTap: () {
              Navigator.of(context).pop();
              onExport('csv');
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('PDF (.pdf)'),
            onTap: () {
              Navigator.of(context).pop();
              onExport('pdf');
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }
}

class FilterDialog extends StatelessWidget {
  final CourseStatus? selectedStatus;
  final CourseLevel? selectedLevel;
  final String? selectedCategory;
  final bool? selectedIsFree;
  final List<String> categories;
  final Function(CourseStatus?, CourseLevel?, String?, bool?) onApply;
  final VoidCallback onClear;

  const FilterDialog({
    super.key,
    this.selectedStatus,
    this.selectedLevel,
    this.selectedCategory,
    this.selectedIsFree,
    required this.categories,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تصفية النتائج'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الحالة:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...CourseStatus.values.map((status) => CheckboxListTile(
                  title: Text(_getStatusText(status)),
                  value: selectedStatus == status,
                  onChanged: (value) {
                    // Handle status selection
                  },
                )),
            const Divider(),
            const Text('المستوى:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...CourseLevel.values.map((level) => CheckboxListTile(
                  title: Text(_getLevelText(level)),
                  value: selectedLevel == level,
                  onChanged: (value) {
                    // Handle level selection
                  },
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClear,
          child: const Text('مسح الكل'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onApply(selectedStatus, selectedLevel, selectedCategory,
                selectedIsFree);
          },
          child: const Text('تطبيق'),
        ),
      ],
    );
  }

  String _getStatusText(CourseStatus status) {
    switch (status) {
      case CourseStatus.draft:
        return 'مسودة';
      case CourseStatus.pending_review:
        return 'قيد المراجعة';
      case CourseStatus.published:
        return 'منشورة';
      case CourseStatus.archived:
        return 'مؤرشفة';
    }
  }

  String _getLevelText(CourseLevel level) {
    switch (level) {
      case CourseLevel.beginner:
        return 'مبتدئ';
      case CourseLevel.intermediate:
        return 'متوسط';
      case CourseLevel.advanced:
        return 'متقدم';
    }
  }
}

// نوافذ حوار إضافية
class ImportDialog extends StatelessWidget {
  final String title;
  final Function(Map<String, dynamic>) onImport;

  const ImportDialog({
    super.key,
    required this.title,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('استيراد $title'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('اختر ملف للاستيراد'),
          SizedBox(height: 20),
          // يمكن إضافة file picker هنا
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onImport({});
          },
          child: const Text('استيراد'),
        ),
      ],
    );
  }
}

class EditProfileDialog extends StatelessWidget {
  final User user;
  final Function(User) onSave;

  const EditProfileDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل الملف الشخصي'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'الاسم'),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onSave(user);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

class ChangePasswordDialog extends StatelessWidget {
  const ChangePasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تغيير كلمة المرور'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'كلمة المرور الحالية'),
          ),
          SizedBox(height: 16),
          TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'كلمة المرور الجديدة'),
          ),
          SizedBox(height: 16),
          TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'تأكيد كلمة المرور'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('تغيير'),
        ),
      ],
    );
  }
}

class LoginHistoryDialog extends StatelessWidget {
  const LoginHistoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('سجل تسجيل الدخول'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('آخر تسجيل دخول: اليوم 10:30 ص'),
          SizedBox(height: 8),
          Text('الجهاز: Chrome على Windows'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('موافق'),
        ),
      ],
    );
  }
}

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('سياسة الخصوصية'),
      content: const SingleChildScrollView(
        child: Text('هنا نص سياسة الخصوصية...'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('موافق'),
        ),
      ],
    );
  }
}

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('حذف الحساب'),
      content: const Text(
          'هل أنت متأكد من رغبتك في حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('حذف', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class FAQDialog extends StatelessWidget {
  const FAQDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('الأسئلة الشائعة'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('س: كيف أضيف كورس جديد؟'),
            Text('ج: اذهب إلى صفحة الكورسات واضغط على إضافة كورس جديد.'),
            SizedBox(height: 16),
            Text('س: كيف أتواصل مع الطلاب؟'),
            Text('ج: يمكنك استخدام نظام الرسائل المدمج في المنصة.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('موافق'),
        ),
      ],
    );
  }
}

class SupportDialog extends StatelessWidget {
  const SupportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('الدعم الفني'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('للحصول على المساعدة، يرجى التواصل معنا:'),
          SizedBox(height: 16),
          Text('البريد الإلكتروني: support@wasla.edu'),
          Text('الهاتف: +967 1 234567'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('موافق'),
        ),
      ],
    );
  }
}

class BugReportDialog extends StatelessWidget {
  const BugReportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('الإبلاغ عن خطأ'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'وصف المشكلة'),
            maxLines: 3,
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: 'خطوات إعادة المشكلة'),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إرسال'),
        ),
      ],
    );
  }
}

class TermsDialog extends StatelessWidget {
  const TermsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('شروط الاستخدام'),
      content: const SingleChildScrollView(
        child: Text('هنا نص شروط الاستخدام...'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('موافق'),
        ),
      ],
    );
  }
}

// نوافذ حوار للطلاب
class AddStudentDialog extends StatelessWidget {
  final Function(String studentId, String courseId) onSave;

  const AddStudentDialog({
    super.key,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تسجيل طالب في كورس'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'معرف الطالب'),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: 'معرف الكورس'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onSave('student_id', 'course_id');
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

class EditStudentDialog extends StatelessWidget {
  final Enrollment enrollment;
  final Function(Enrollment) onSave;

  const EditStudentDialog({
    super.key,
    required this.enrollment,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل بيانات التسجيل'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('الطالب: ${enrollment.studentId}'),
          const SizedBox(height: 16),
          Text('الكورس: ${enrollment.courseId}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onSave(enrollment);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

class StudentFilterDialog extends StatelessWidget {
  final EnrollmentStatus? selectedStatus;
  final String? selectedCourse;
  final List<String> courses;
  final Function(EnrollmentStatus?, String?) onApply;
  final VoidCallback onClear;

  const StudentFilterDialog({
    super.key,
    this.selectedStatus,
    this.selectedCourse,
    required this.courses,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تصفية الطلاب'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('فلاتر الطلاب ستكون هنا'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onClear,
          child: const Text('مسح الكل'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onApply(selectedStatus, selectedCourse);
          },
          child: const Text('تطبيق'),
        ),
      ],
    );
  }
}

class EnrollToCourseDialog extends StatelessWidget {
  final String studentId;
  final Function(String) onEnroll;

  const EnrollToCourseDialog({
    super.key,
    required this.studentId,
    required this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تسجيل الطالب في كورس'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('اختر الكورس للتسجيل فيه'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onEnroll('course_id');
          },
          child: const Text('تسجيل'),
        ),
      ],
    );
  }
}
