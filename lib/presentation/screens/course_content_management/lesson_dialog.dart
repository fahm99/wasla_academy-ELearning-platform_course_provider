import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/data/models/lesson.dart';
import 'package:course_provider/data/repositories/main_repository.dart';
import 'package:course_provider/core/utils/video_helper.dart';

class LessonDialog extends StatefulWidget {
  final String moduleId;
  final String courseId;
  final Lesson? lesson;
  final LessonType? initialType;

  const LessonDialog({
    super.key,
    required this.moduleId,
    required this.courseId,
    this.lesson,
    this.initialType,
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
  PlatformFile? _pickedFileResult; // للويب
  bool _isUploading = false;
  double _uploadProgress = 0.0; // نسبة التقدم
  String? _uploadedFileUrl;
  VideoInfo? _videoInfo; // معلومات الفيديو
  bool _isCompressing = false; // حالة الضغط

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
    } else if (widget.initialType != null) {
      _selectedType = widget.initialType!;
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

  /// الحصول على اسم الملف بشكل آمن (يعمل على جميع المنصات)
  String _getFileName(File file) {
    try {
      return file.path.split('/').last;
    } catch (e) {
      try {
        return file.path.split('\\').last;
      } catch (e2) {
        return 'ملف محدد';
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      print('[Wasla] بدء اختيار الملف - النوع: ${_selectedType.name}');

      FilePickerResult? result;

      if (_selectedType == LessonType.video) {
        print('[Wasla] فتح منتقي الفيديو...');
        result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
          withData: true,
        );
      } else if (_selectedType == LessonType.file) {
        print('[Wasla] فتح منتقي الملفات...');
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
          allowMultiple: false,
          withData: true,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        final fileSize = pickedFile.size;
        final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

        print('[Wasla] تم اختيار الملف بنجاح:');
        print('[Wasla]   - الاسم: ${pickedFile.name}');
        print('[Wasla]   - الحجم: $fileSizeMB MB ($fileSize bytes)');
        print('[Wasla]   - النوع: ${pickedFile.extension}');
        print('[Wasla]   - البيانات متوفرة: ${pickedFile.bytes != null}');

        setState(() {
          try {
            final path = pickedFile.path;
            if (path != null) {
              _selectedFile = File(path);
              print('[Wasla]   - تم حفظ File من path');
            } else {
              _selectedFile = null;
              print('[Wasla]   - path = null، سنستخدم bytes');
            }
          } catch (e) {
            _selectedFile = null;
            print('[Wasla]   - path غير متاح (Web)، سنستخدم bytes');
          }
          _pickedFileResult = pickedFile;
        });

        // استخراج معلومات الفيديو تلقائياً
        if (_selectedType == LessonType.video) {
          if (_selectedFile != null) {
            // للموبايل/ديسكتوب: استخراج كامل المعلومات
            await _extractVideoInfo();
          } else {
            // للويب: استخراج الاسم فقط من اسم الملف
            await _extractVideoInfoFromFileName(pickedFile.name);
          }
        }
      } else {
        print('[Wasla] لم يتم اختيار أي ملف');
      }
    } catch (e, stackTrace) {
      print('[Wasla] ❌ خطأ في اختيار الملف: $e');
      print('[Wasla] Stack trace: $stackTrace');

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

  /// استخراج معلومات الفيديو وملء الحقول تلقائياً
  Future<void> _extractVideoInfo() async {
    if (_selectedFile == null) return;

    try {
      print('[Wasla] استخراج معلومات الفيديو...');

      final info = await VideoHelper.extractVideoInfo(_selectedFile!);

      if (info != null && mounted) {
        setState(() {
          _videoInfo = info;

          // ملء الحقول تلقائياً
          if (_titleController.text.isEmpty) {
            _titleController.text = info.name;
          }
          if (_descriptionController.text.isEmpty) {
            _descriptionController.text = info.name;
          }
          _videoDurationController.text = info.durationInMinutes.toString();
        });

        print('[Wasla] ✅ تم ملء الحقول تلقائياً');
        print('[Wasla]   - العنوان: ${info.name}');
        print('[Wasla]   - المدة: ${info.durationInMinutes} دقيقة');
      }
    } catch (e) {
      print('[Wasla] ❌ خطأ في استخراج معلومات الفيديو: $e');
      // لا نعرض رسالة خطأ للمستخدم، فقط نتجاهل
    }
  }

  /// استخراج معلومات الفيديو من اسم الملف (للويب)
  Future<void> _extractVideoInfoFromFileName(String fileName) async {
    try {
      print('[Wasla] استخراج معلومات من اسم الملف (Web)...');

      // إزالة الامتداد من اسم الملف
      final videoName = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');

      if (mounted) {
        setState(() {
          // ملء الحقول تلقائياً
          if (_titleController.text.isEmpty) {
            _titleController.text = videoName;
          }
          if (_descriptionController.text.isEmpty) {
            _descriptionController.text = videoName;
          }
        });

        print('[Wasla] ✅ تم ملء الحقول من اسم الملف');
        print('[Wasla]   - العنوان: $videoName');
        print('[Wasla]   - الوصف: $videoName');
        print('[Wasla]   ⚠️ المدة غير متاحة على Web، يرجى إدخالها يدوياً');
      }
    } catch (e) {
      print('[Wasla] ❌ خطأ في استخراج معلومات من اسم الملف: $e');
    }
  }

  Future<String?> _uploadFile() async {
    if (_selectedFile == null && _pickedFileResult == null) {
      print(
          '[Wasla] لا يوجد ملف لرفعه، استخدام الرابط الموجود: $_uploadedFileUrl');
      return _uploadedFileUrl;
    }

    print('[Wasla] ========================================');
    print('[Wasla] بدء عملية رفع الملف');
    print('[Wasla] ========================================');

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final repository = context.read<MainRepository>();

      // محاكاة التقدم
      _simulateProgress();

      String? url;
      File? fileToUpload = _selectedFile;

      if (_selectedType == LessonType.video && _selectedFile != null) {
        print('[Wasla] 📹 بدء معالجة الفيديو...');

        // ضغط الفيديو إذا كان كبيراً
        final fileSize = await _selectedFile!.length();
        if (fileSize > 50 * 1024 * 1024) {
          print('[Wasla] 🗜️ الفيديو كبير، بدء الضغط...');
          setState(() {
            _isCompressing = true;
            _uploadProgress = 0.1;
          });

          final compressedFile = await VideoHelper.compressVideo(
            _selectedFile!,
            onProgress: (progress) {
              if (mounted) {
                setState(() {
                  _uploadProgress = 0.1 + (progress * 0.3); // 10-40%
                });
              }
            },
          );

          if (compressedFile != null) {
            fileToUpload = compressedFile;
            print('[Wasla] ✅ تم ضغط الفيديو بنجاح');
          }

          setState(() {
            _isCompressing = false;
            _uploadProgress = 0.4;
          });
        }

        // رفع الفيديو
        print('[Wasla] 📤 بدء رفع الفيديو...');
        url = await repository.uploadVideo(
          videoFile: fileToUpload!,
          courseId: widget.courseId,
          lessonId: widget.lesson?.id ?? 'temp',
        );
      } else if (_selectedType == LessonType.video &&
          _pickedFileResult != null) {
        // للويب: استخدام bytes
        print('[Wasla] 📤 رفع الفيديو من الويب...');
        url = await repository.uploadVideoFromBytes(
          videoBytes: _pickedFileResult!.bytes!,
          fileName: _pickedFileResult!.name,
          courseId: widget.courseId,
          lessonId: widget.lesson?.id ?? 'temp',
        );
      } else if (_selectedType == LessonType.file) {
        print('[Wasla] 📄 بدء رفع الملف...');

        if (_pickedFileResult != null) {
          url = await repository.uploadFileFromBytes(
            fileBytes: _pickedFileResult!.bytes!,
            fileName: _pickedFileResult!.name,
            courseId: widget.courseId,
            lessonId: widget.lesson?.id ?? 'temp',
            fileType: _pickedFileResult!.extension ?? '',
          );
        } else if (_selectedFile != null) {
          url = await repository.uploadFile(
            file: _selectedFile!,
            courseId: widget.courseId,
            lessonId: widget.lesson?.id ?? 'temp',
            fileType: _selectedFile!.path.split('.').last,
          );
        }
      }

      setState(() {
        _isUploading = false;
        _isCompressing = false;
        _uploadProgress = 1.0;
        _uploadedFileUrl = url;
      });

      if (url != null) {
        print('[Wasla] ✅ تم رفع الملف بنجاح!');
        print('[Wasla] الرابط: $url');

        // تنظيف الملفات المؤقتة
        await VideoHelper.cleanup();
      } else {
        print('[Wasla] ❌ فشل رفع الملف');
      }

      return url;
    } catch (e, stackTrace) {
      print('[Wasla] ❌ خطأ في رفع الملف: $e');
      print('[Wasla] Stack trace: $stackTrace');

      setState(() {
        _isUploading = false;
        _isCompressing = false;
        _uploadProgress = 0.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفع الملف: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return null;
    }
  }

  /// محاكاة تقدم الرفع
  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_isUploading && mounted && !_isCompressing) {
        setState(() => _uploadProgress = 0.5);
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isUploading && mounted && !_isCompressing) {
        setState(() => _uploadProgress = 0.7);
      }
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_isUploading && mounted && !_isCompressing) {
        setState(() => _uploadProgress = 0.9);
      }
    });
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
    if (_selectedFile != null || _pickedFileResult != null) {
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
    final isQuiz = _selectedType == LessonType.quiz;
    final title = widget.lesson == null
        ? (isQuiz ? 'إضافة امتحان جديد' : 'إضافة درس جديد')
        : (isQuiz ? 'تعديل الامتحان' : 'تعديل الدرس');
    final icon = isQuiz ? Icons.quiz : Icons.video_library;

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
          Icon(icon, color: AppTheme.yellow),
          const SizedBox(width: 12),
          Text(
            title,
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
          _pickedFileResult = null;
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
        if (_selectedFile != null ||
            _pickedFileResult != null ||
            _uploadedFileUrl != null)
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
                Flexible(
                  child: Text(
                    _pickedFileResult != null
                        ? _pickedFileResult!.name
                        : _selectedFile != null
                            ? _getFileName(_selectedFile!)
                            : 'ملف مرفوع مسبقاً',
                    style: const TextStyle(color: AppTheme.darkBlue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedFile != null || _pickedFileResult != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                        _pickedFileResult = null;
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
        if (_selectedFile != null ||
            _pickedFileResult != null ||
            _uploadedFileUrl != null)
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
                Flexible(
                  child: Text(
                    _pickedFileResult != null
                        ? _pickedFileResult!.name
                        : _selectedFile != null
                            ? _getFileName(_selectedFile!)
                            : 'ملف مرفوع مسبقاً',
                    style: const TextStyle(color: AppTheme.darkBlue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedFile != null || _pickedFileResult != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                        _pickedFileResult = null;
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
          Flexible(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مؤشر التقدم
          if (_isUploading || _isCompressing) _buildUploadProgress(),
          if (_isUploading || _isCompressing) const SizedBox(height: 16),

          // الأزرار
          Row(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
        ],
      ),
    );
  }

  /// مؤشر التقدم المفصل
  Widget _buildUploadProgress() {
    final percentage = (_uploadProgress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _uploadProgress,
                      strokeWidth: 3,
                      backgroundColor: AppTheme.mediumGray.withOpacity(0.3),
                      valueColor:
                          const AlwaysStoppedAnimation(AppTheme.darkBlue),
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCompressing
                          ? 'جاري ضغط الفيديو...'
                          : 'جاري رفع الملف...',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBlue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isCompressing
                          ? 'يرجى الانتظار، قد يستغرق هذا بضع دقائق'
                          : 'يرجى عدم إغلاق النافذة',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGray.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // شريط التقدم
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _uploadProgress,
              minHeight: 6,
              backgroundColor: AppTheme.mediumGray.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(AppTheme.darkBlue),
            ),
          ),
        ],
      ),
    );
  }
}
