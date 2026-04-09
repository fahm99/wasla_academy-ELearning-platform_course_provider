import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/data/models/lesson.dart';
import 'package:course_provider/data/repositories/main_repository.dart';

class LessonDialog extends StatefulWidget {
  final String moduleId;
  final String courseId;
  final Lesson? lesson;

  const LessonDialog({
    super.key,
    required this.moduleId,
    required this.courseId,
    this.lesson,
  });

  @override
  State<LessonDialog> createState() => _LessonDialogState();
}

class _LessonDialogState extends State<LessonDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _videoDurationController;
  late TextEditingController _videoUrlController;
  late TextEditingController _contentController;

  LessonType _selectedType = LessonType.video;
  File? _selectedFile;
  bool _isUploading = false;
  String? _uploadedFileUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.lesson?.title);
    _descriptionController =
        TextEditingController(text: widget.lesson?.description);
    _videoDurationController = TextEditingController(
      text: widget.lesson?.videoDuration?.toString(),
    );
    _videoUrlController = TextEditingController(text: widget.lesson?.videoUrl);
    _contentController = TextEditingController(text: widget.lesson?.content);

    if (widget.lesson != null) {
      _selectedType = widget.lesson!.lessonType ?? LessonType.video;
      _uploadedFileUrl = widget.lesson!.videoUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoDurationController.dispose();
    _videoUrlController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result;

      if (_selectedType == LessonType.video) {
        result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );
      } else if (_selectedType == LessonType.file) {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
          allowMultiple: false,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الملف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadFile() async {
    if (_selectedFile == null) return _uploadedFileUrl;

    setState(() => _isUploading = true);

    try {
      final repository = context.read<MainRepository>();
      String? url;

      if (_selectedType == LessonType.video) {
        url = await repository.uploadVideo(
          videoFile: _selectedFile!,
          courseId: widget.courseId,
          lessonId: widget.lesson?.id ?? 'temp',
        );
      } else if (_selectedType == LessonType.file) {
        url = await repository.uploadFile(
          file: _selectedFile!,
          courseId: widget.courseId,
          lessonId: widget.lesson?.id ?? 'temp',
          fileType: _selectedFile!.path.split('.').last,
        );
      }

      setState(() {
        _isUploading = false;
        _uploadedFileUrl = url;
      });

      return url;
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفع الملف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال عنوان الدرس'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // رفع الملف إذا كان موجوداً
    String? fileUrl = _uploadedFileUrl;
    if (_selectedFile != null) {
      fileUrl = await _uploadFile();
      if (fileUrl == null) {
        return; // فشل الرفع
      }
    }

    final data = {
      'title': _titleController.text,
      'description': _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      'lessonType': _selectedType,
      'videoUrl':
          _selectedType == LessonType.video || _selectedType == LessonType.file
              ? fileUrl
              : null,
      'videoDuration': _selectedType == LessonType.video &&
              _videoDurationController.text.isNotEmpty
          ? int.tryParse(_videoDurationController.text)
          : null,
      'content':
          _selectedType == LessonType.text ? _contentController.text : null,
    };

    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: 20),
                    _buildTitleField(),
                    const SizedBox(height: 16),
                    _buildDescriptionField(),
                    const SizedBox(height: 20),
                    _buildTypeSpecificFields(),
                  ],
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.darkBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.video_library, color: AppTheme.yellow),
          const SizedBox(width: 12),
          Text(
            widget.lesson == null ? 'إضافة درس جديد' : 'تعديل الدرس',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppTheme.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع الدرس',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeChip(LessonType.video, 'فيديو', Icons.play_circle),
            _buildTypeChip(LessonType.text, 'نص', Icons.article),
            _buildTypeChip(LessonType.file, 'ملف', Icons.attach_file),
            _buildTypeChip(LessonType.quiz, 'اختبار', Icons.quiz),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(LessonType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedType = type;
          _selectedFile = null;
          _uploadedFileUrl = null;
        });
      },
      backgroundColor: AppTheme.white,
      selectedColor: AppTheme.darkBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.white : AppTheme.darkBlue,
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'عنوان الدرس *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'الوصف (اختياري)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
    );
  }

  Widget _buildTypeSpecificFields() {
    switch (_selectedType) {
      case LessonType.video:
        return _buildVideoFields();
      case LessonType.text:
        return _buildTextFields();
      case LessonType.file:
        return _buildFileFields();
      case LessonType.quiz:
        return _buildQuizFields();
    }
  }

  Widget _buildVideoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ملف الفيديو',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedFile != null || _uploadedFileUrl != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedFile != null
                        ? _selectedFile!.path.split('/').last
                        : 'ملف مرفوع مسبقاً',
                    style: const TextStyle(color: AppTheme.darkBlue),
                  ),
                ),
                if (_selectedFile != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
              ],
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('اختر ملف فيديو'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkBlue,
              foregroundColor: AppTheme.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _videoDurationController,
          decoration: const InputDecoration(
            labelText: 'مدة الفيديو (بالدقائق)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.timer),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'محتوى الدرس',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contentController,
          decoration: const InputDecoration(
            labelText: 'اكتب محتوى الدرس هنا',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 10,
        ),
      ],
    );
  }

  Widget _buildFileFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ملف الدرس',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedFile != null || _uploadedFileUrl != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedFile != null
                        ? _selectedFile!.path.split('/').last
                        : 'ملف مرفوع مسبقاً',
                    style: const TextStyle(color: AppTheme.darkBlue),
                  ),
                ),
                if (_selectedFile != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
              ],
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('اختر ملف (PDF, DOC, PPT)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkBlue,
              foregroundColor: AppTheme.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
      ],
    );
  }

  Widget _buildQuizFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.yellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.yellow),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, color: AppTheme.yellow),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'سيتم إنشاء الاختبار بعد حفظ الدرس',
              style: TextStyle(color: AppTheme.darkBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        border: Border(
          top: BorderSide(color: AppTheme.darkBlue.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isUploading ? null : () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isUploading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkBlue,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppTheme.white),
                    ),
                  )
                : const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
