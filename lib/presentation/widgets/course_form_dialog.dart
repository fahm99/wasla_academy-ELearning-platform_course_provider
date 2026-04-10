import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/course.dart';
import '../../data/repositories/main_repository.dart';
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

  // لرفع الصورة
  File? _selectedImageFile;
  PlatformFile? _pickedImageFile;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

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
    _uploadedImageUrl = course.imageUrl; // حفظ رابط الصورة الموجود
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
      children: [
        // زر العودة
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.darkBlue,
          tooltip: 'العودة',
        ),
        const SizedBox(width: 8),
        // العنوان
        Expanded(
          child: Text(
            isEditing ? 'تعديل الكورس' : 'إضافة كورس جديد',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkBlue,
            ),
          ),
        ),
        // زر الإغلاق
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          color: AppTheme.darkGray,
          tooltip: 'إغلاق',
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
            _buildImageUploadSection(),
            const SizedBox(height: 24),
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

  /// قسم رفع الصورة التعريفية
  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الصورة التعريفية للكورس',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkBlue,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedImageFile != null ||
            _pickedImageFile != null ||
            _uploadedImageUrl != null)
          _buildImagePreview()
        else
          _buildImageUploadButton(),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumGray),
        color: AppTheme.lightGray,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _pickedImageFile != null && _pickedImageFile!.bytes != null
                ? Image.memory(
                    _pickedImageFile!.bytes!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : _selectedImageFile != null
                    ? Image.file(
                        _selectedImageFile!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : _uploadedImageUrl != null
                        ? Image.network(
                            _uploadedImageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image,
                                    size: 50, color: AppTheme.mediumGray),
                              );
                            },
                          )
                        : const SizedBox(),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedImageFile = null;
                  _pickedImageFile = null;
                  _uploadedImageUrl = null;
                });
              },
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
            ),
          ),
          if (_isUploadingImage)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageUploadButton() {
    return InkWell(
      onTap: _isUploadingImage ? null : _pickImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTheme.mediumGray, width: 2, style: BorderStyle.solid),
          color: AppTheme.lightGray.withOpacity(0.3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 60,
              color: AppTheme.darkBlue.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'اضغط لاختيار صورة',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkBlue.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'JPG, PNG (الحد الأقصى 5 MB)',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.darkGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      print('[Wasla] بدء اختيار صورة الكورس');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        final fileSize = pickedFile.size;
        final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

        // التحقق من حجم الملف (5 MB كحد أقصى)
        if (fileSize > 5 * 1024 * 1024) {
          _showErrorSnackBar('حجم الصورة كبير جداً. الحد الأقصى 5 MB');
          return;
        }

        print('[Wasla] تم اختيار الصورة:');
        print('[Wasla]   - الاسم: ${pickedFile.name}');
        print('[Wasla]   - الحجم: $fileSizeMB MB');

        setState(() {
          try {
            final path = pickedFile.path;
            if (path != null) {
              _selectedImageFile = File(path);
            } else {
              _selectedImageFile = null;
            }
          } catch (e) {
            _selectedImageFile = null;
          }
          _pickedImageFile = pickedFile;
        });
      }
    } catch (e) {
      print('[Wasla] ❌ خطأ في اختيار الصورة: $e');
      _showErrorSnackBar('حدث خطأ أثناء اختيار الصورة');
    }
  }

  Future<String?> _uploadCourseImage(String courseId) async {
    if (_selectedImageFile == null && _pickedImageFile == null) {
      return _uploadedImageUrl; // إرجاع الرابط الموجود
    }

    setState(() => _isUploadingImage = true);

    try {
      final repository = context.read<MainRepository>();
      String? url;

      if (_pickedImageFile != null && _pickedImageFile!.bytes != null) {
        // للويب: استخدام bytes
        print('[Wasla] رفع صورة الكورس من bytes (Web)');
        url = await repository.uploadImageFromBytes(
          imageBytes: _pickedImageFile!.bytes!,
          fileName: _pickedImageFile!.name,
          courseId: courseId,
          type: 'cover',
        );
      } else if (_selectedImageFile != null) {
        // للموبايل/ديسكتوب: استخدام File
        print('[Wasla] رفع صورة الكورس من File');
        url = await repository.uploadImage(
          imageFile: _selectedImageFile!,
          courseId: courseId,
          type: 'cover',
        );
      }

      setState(() => _isUploadingImage = false);

      if (url != null) {
        print('[Wasla] ✅ تم رفع صورة الكورس بنجاح: $url');
      }

      return url;
    } catch (e) {
      print('[Wasla] ❌ خطأ في رفع صورة الكورس: $e');
      setState(() => _isUploadingImage = false);
      return null;
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

      final courseId =
          widget.course?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      // رفع الصورة إذا تم اختيار صورة جديدة
      String? imageUrl = _uploadedImageUrl;
      if (_selectedImageFile != null || _pickedImageFile != null) {
        imageUrl = await _uploadCourseImage(courseId);
        if (imageUrl == null &&
            (_selectedImageFile != null || _pickedImageFile != null)) {
          _showErrorSnackBar('فشل رفع صورة الكورس');
          setState(() => _isLoading = false);
          return;
        }
      }

      final course = Course(
        id: courseId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        level: _selectedLevel,
        price: double.parse(_priceController.text.trim()),
        durationHours: _durationController.text.trim().isNotEmpty
            ? int.parse(_durationController.text.trim())
            : null,
        coverImageUrl: imageUrl, // استخدام coverImageUrl
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
