import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/course.dart';
import '../blocs/course/course_bloc.dart';
import '../blocs/course/course_event.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';

class CourseFormDialog extends StatefulWidget {
  final Course? course;

  const CourseFormDialog({super.key, this.course});

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedCategory = 'تقنية';
  CourseLevel _selectedLevel = CourseLevel.beginner;
  bool _isLoading = false;

  final List<String> _categories = [
    'تقنية',
    'لغات',
    'تنمية بشرية',
    'أعمال',
    'تصميم',
    'تسويق',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _initializeFields();
    }
  }

  void _initializeFields() {
    final course = widget.course!;
    _titleController.text = course.title;
    _descriptionController.text = course.description;
    _priceController.text = course.price.toString();
    _durationController.text = course.durationHours?.toString() ?? '';
    _selectedCategory = course.category ?? 'تقنية';
    _selectedLevel = course.level ?? CourseLevel.beginner;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeader(isEditing),
            const SizedBox(height: 24),
            Expanded(child: _buildForm()),
            const SizedBox(height: 24),
            _buildActions(isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEditing ? 'تعديل الكورس' : 'إضافة كورس جديد',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          color: AppTheme.darkGray,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _titleController,
              label: 'عنوان الكورس',
              hint: 'أدخل عنوان الكورس',
              validator: Validators.validateCourseTitle,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'وصف الكورس',
              hint: 'أدخل وصفاً مفصلاً للكورس',
              maxLines: 4,
              validator: Validators.validateCourseDescription,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'التصنيف',
                    value: _selectedCategory,
                    items: _categories,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLevelDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: 'السعر (ريال سعودي)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: Validators.validatePrice,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _durationController,
                    label: 'المدة (ساعة)',
                    hint: '10',
                    keyboardType: TextInputType.number,
                    validator: Validators.validateDuration,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.mediumGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.darkBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.mediumGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.darkBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildLevelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المستوى',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<CourseLevel>(
          value: _selectedLevel,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.mediumGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.darkBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: CourseLevel.values.map((level) {
            return DropdownMenuItem<CourseLevel>(
              value: level,
              child: Text(_getLevelText(level)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLevel = value!;
            });
          },
        ),
      ],
    );
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

  Widget _buildActions(bool isEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCourse,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkBlue,
            foregroundColor: AppTheme.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                  ),
                )
              : Text(isEditing ? 'حفظ التغييرات' : 'إضافة الكورس'),
        ),
      ],
    );
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // الحصول على المستخدم الحالي
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        _showErrorSnackBar('يجب تسجيل الدخول أولاً');
        return;
      }

      final user = authState.user;
      final isEditing = widget.course != null;

      final course = Course(
        id: widget.course?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        level: _selectedLevel,
        price: double.parse(_priceController.text.trim()),
        durationHours: _durationController.text.trim().isNotEmpty
            ? int.parse(_durationController.text.trim())
            : null,
        providerId: user.id,
        status: widget.course?.status ?? CourseStatus.draft,
        studentsCount: widget.course?.studentsCount ?? 0,
        rating: widget.course?.rating ?? 0.0,
        reviewsCount: widget.course?.reviewsCount ?? 0,
        isFeatured: widget.course?.isFeatured ?? false,
        createdAt: widget.course?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        context.read<CourseBloc>().add(CourseUpdateRequested(course: course));
      } else {
        context.read<CourseBloc>().add(CourseAddRequested(course: course));
      }

      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar(
          isEditing ? 'تم تحديث الكورس بنجاح' : 'تم إضافة الكورس بنجاح',
        );
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء حفظ الكورس');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      SnackBarHelper.showSuccess(context, message);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      SnackBarHelper.showError(context, message);
    }
  }
}
