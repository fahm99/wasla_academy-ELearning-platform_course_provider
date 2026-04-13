import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/core/utils/app_icons.dart';
import 'package:course_provider/data/models/course.dart';
import 'package:course_provider/data/models/module.dart' as models;
import 'package:course_provider/data/models/lesson.dart';
import 'package:course_provider/data/repositories/main_repository.dart';
import 'course_content_management/lesson_dialog.dart';
import 'exam_management_screen.dart';

class CourseContentManagementScreen extends StatefulWidget {
  final Course course;

  const CourseContentManagementScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseContentManagementScreen> createState() =>
      _CourseContentManagementScreenState();
}

class _CourseContentManagementScreenState
    extends State<CourseContentManagementScreen> {
  List<models.Module> _modules = [];
  Map<String, List<Lesson>> _moduleLessons = {};
  int _selectedModuleIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);

    try {
      final repository = context.read<MainRepository>();

      // جلب الوحدات
      final modules = await repository.getCourseModules(widget.course.id);

      // جلب دروس كل وحدة
      final lessonsMap = <String, List<Lesson>>{};
      for (final module in modules) {
        final lessons = await repository.getModuleLessons(module.id);
        lessonsMap[module.id] = lessons;
      }

      setState(() {
        _modules = modules;
        _moduleLessons = lessonsMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل المحتوى: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return WillPopScope(
      onWillPop: () async {
        // منع العودة إلى شاشة تسجيل الدخول
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          backgroundColor: AppTheme.darkBlue,
          foregroundColor: AppTheme.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'العودة',
          ),
          title: Text('إدارة محتوى: ${widget.course.title}'),
          actions: [
            IconButton(
              onPressed: () => _navigateToExamManagement(context),
              icon: const Icon(Icons.quiz),
              tooltip: 'إدارة الامتحانات',
            ),
            IconButton(
              onPressed: _loadContent,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : isMobile
                ? _buildMobileLayout()
                : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildModulesDropdown(),
        Expanded(child: _buildLessonsContent()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildModulesSidebar(),
        Expanded(child: _buildLessonsContent()),
      ],
    );
  }

  Widget _buildModulesSidebar() {
    return Container(
      width: 300,
      color: AppTheme.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.lightGray)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الوحدات الدراسية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
                IconButton(
                  onPressed: _addNewModule,
                  icon: const Icon(AppIcons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.darkBlue,
                    foregroundColor: AppTheme.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _modules.isEmpty
                ? _buildEmptyModules()
                : ReorderableListView.builder(
                    itemCount: _modules.length,
                    onReorder: _reorderModules,
                    itemBuilder: (context, index) {
                      final module = _modules[index];
                      final isSelected = index == _selectedModuleIndex;
                      return _buildModuleItem(module, index, isSelected);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleItem(models.Module module, int index, bool isSelected) {
    final lessonsCount = _moduleLessons[module.id]?.length ?? 0;

    return Container(
      key: ValueKey(module.id),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.darkBlue.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border:
            isSelected ? Border.all(color: AppTheme.darkBlue, width: 2) : null,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.darkBlue,
          foregroundColor: AppTheme.white,
          child: Text('${index + 1}'),
        ),
        title: Text(
          module.title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('$lessonsCount دروس'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(AppIcons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('تعديل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _editModule(module);
            } else if (value == 'delete') {
              _deleteModule(module);
            }
          },
        ),
        onTap: () {
          setState(() {
            _selectedModuleIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildModulesDropdown() {
    if (_modules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: AppTheme.white,
        child: ElevatedButton.icon(
          onPressed: _addNewModule,
          icon: const Icon(AppIcons.add),
          label: const Text('إضافة وحدة جديدة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkBlue,
            foregroundColor: AppTheme.white,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: DropdownButtonFormField<int>(
        value: _selectedModuleIndex,
        decoration: const InputDecoration(
          labelText: 'اختر الوحدة',
          border: OutlineInputBorder(),
        ),
        items: _modules.asMap().entries.map((entry) {
          return DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value.title),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedModuleIndex = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildLessonsContent() {
    if (_modules.isEmpty) {
      return _buildEmptyModules();
    }

    final module = _modules[_selectedModuleIndex];
    final lessons = _moduleLessons[module.id] ?? [];

    return Container(
      color: AppTheme.white,
      child: Column(
        children: [
          _buildLessonsHeader(module, lessons.length),
          Expanded(
            child: lessons.isEmpty
                ? _buildEmptyLessons()
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: lessons.length,
                    onReorder: (oldIndex, newIndex) =>
                        _reorderLessons(module.id, oldIndex, newIndex),
                    itemBuilder: (context, index) {
                      return _buildLessonCard(lessons[index], index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsHeader(models.Module module, int lessonsCount) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.lightGray)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                    Text(
                      '$lessonsCount دروس',
                      style: const TextStyle(
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // أزرار الإضافة
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _addNewLesson(module.id),
                icon: const Icon(Icons.video_library),
                label: Text(isMobile ? 'درس' : 'إضافة درس'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkBlue,
                  foregroundColor: AppTheme.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _addNewQuiz(module.id),
                icon: const Icon(Icons.quiz),
                label: Text(isMobile ? 'امتحان' : 'إضافة امتحان'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.red,
                  foregroundColor: AppTheme.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson, int index) {
    final lessonType = lesson.lessonType ?? LessonType.video;

    return Card(
      key: ValueKey(lesson.id),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getLessonTypeColor(lessonType),
          child: Icon(
            _getLessonTypeIcon(lessonType),
            color: AppTheme.white,
          ),
        ),
        title: Text(lesson.title),
        subtitle: Text(_getLessonTypeLabel(lessonType)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lesson.videoDuration != null)
              Chip(
                label: Text('${lesson.videoDuration} دقيقة'),
                backgroundColor: AppTheme.lightGray,
              ),
            const SizedBox(width: 8),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(AppIcons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('تعديل'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _editLesson(lesson);
                } else if (value == 'delete') {
                  _deleteLesson(lesson);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyModules() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_open,
            size: 64,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد وحدات دراسية',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewModule,
            icon: const Icon(AppIcons.add),
            label: const Text('إضافة وحدة جديدة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkBlue,
              foregroundColor: AppTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLessons() {
    final module = _modules[_selectedModuleIndex];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.video_library,
            size: 64,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد دروس في هذه الوحدة',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بإضافة درس أو امتحان',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _addNewLesson(module.id),
                icon: const Icon(Icons.video_library),
                label: const Text('إضافة درس'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkBlue,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _addNewQuiz(module.id),
                icon: const Icon(Icons.quiz),
                label: const Text('إضافة امتحان'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.red,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getLessonTypeColor(LessonType type) {
    switch (type) {
      case LessonType.video:
        return AppTheme.blue;
      case LessonType.text:
        return AppTheme.green;
      case LessonType.file:
        return AppTheme.yellow;
      case LessonType.quiz:
        return AppTheme.red;
    }
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Icons.play_circle;
      case LessonType.text:
        return Icons.article;
      case LessonType.file:
        return Icons.attach_file;
      case LessonType.quiz:
        return Icons.quiz;
    }
  }

  String _getLessonTypeLabel(LessonType type) {
    switch (type) {
      case LessonType.video:
        return 'فيديو';
      case LessonType.text:
        return 'نص';
      case LessonType.file:
        return 'ملف';
      case LessonType.quiz:
        return 'اختبار';
    }
  }

  Future<void> _addNewModule() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _ModuleDialog(),
    );

    if (result != null) {
      try {
        final repository = context.read<MainRepository>();
        await repository.createModule(
          courseId: widget.course.id,
          title: result['title'],
          description: result['description'],
          orderNumber: _modules.length + 1,
        );
        await _loadContent();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الوحدة بنجاح'),
              backgroundColor: AppTheme.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في إضافة الوحدة: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editModule(models.Module module) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ModuleDialog(
        title: module.title,
        description: module.description,
      ),
    );

    if (result != null) {
      try {
        final repository = context.read<MainRepository>();
        await repository.updateModule(
          moduleId: module.id,
          title: result['title'],
          description: result['description'],
        );
        await _loadContent();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الوحدة بنجاح'),
              backgroundColor: AppTheme.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في تحديث الوحدة: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteModule(models.Module module) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الوحدة "${module.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repository = context.read<MainRepository>();
        await repository.deleteModule(module.id);
        await _loadContent();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الوحدة بنجاح'),
              backgroundColor: AppTheme.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في حذف الوحدة: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _addNewLesson(String moduleId) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LessonDialog(
        moduleId: moduleId,
        courseId: widget.course.id,
      ),
    );

    if (result != null) {
      try {
        final repository = context.read<MainRepository>();
        await repository.createLesson(
          moduleId: moduleId,
          courseId: widget.course.id,
          title: result['title'],
          description: result['description'],
          lessonType: result['lessonType'],
          videoUrl: result['videoUrl'],
          videoDuration: result['videoDuration'],
          content: result['content'],
          orderNumber: (_moduleLessons[moduleId]?.length ?? 0) + 1,
        );
        await _loadContent();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الدرس بنجاح'),
              backgroundColor: AppTheme.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في إضافة الدرس: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _addNewQuiz(String moduleId) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LessonDialog(
        moduleId: moduleId,
        courseId: widget.course.id,
        initialType: LessonType.quiz,
      ),
    );

    if (result != null) {
      try {
        final repository = context.read<MainRepository>();
        await repository.createLesson(
          moduleId: moduleId,
          courseId: widget.course.id,
          title: result['title'],
          description: result['description'],
          lessonType: result['lessonType'],
          videoUrl: result['videoUrl'],
          videoDuration: result['videoDuration'],
          content: result['content'],
          orderNumber: (_moduleLessons[moduleId]?.length ?? 0) + 1,
        );
        await _loadContent();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الامتحان بنجاح'),
              backgroundColor: AppTheme.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في إضافة الامتحان: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editLesson(Lesson lesson) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LessonDialog(
        moduleId: lesson.moduleId,
        courseId: widget.course.id,
        lesson: lesson,
      ),
    );

    if (result != null) {
      try {
        final repository = context.read<MainRepository>();
        await repository.updateLesson(
          lessonId: lesson.id,
          title: result['title'],
          description: result['description'],
          lessonType: result['lessonType'],
          videoUrl: result['videoUrl'],
          videoDuration: result['videoDuration'],
          content: result['content'],
        );
        await _loadContent();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الدرس بنجاح'),
              backgroundColor: AppTheme.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في تحديث الدرس: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteLesson(Lesson lesson) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الدرس "${lesson.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repository = context.read<MainRepository>();
        await repository.deleteLesson(lesson.id);
        await _loadContent();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الدرس بنجاح'),
              backgroundColor: AppTheme.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في حذف الدرس: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _reorderModules(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final module = _modules.removeAt(oldIndex);
      _modules.insert(newIndex, module);
    });

    try {
      final repository = context.read<MainRepository>();
      final moduleIds = _modules.map((m) => m.id).toList();
      await repository.reorderModules(moduleIds);
    } catch (e) {
      await _loadContent();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إعادة الترتيب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reorderLessons(
      String moduleId, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final lessons = _moduleLessons[moduleId]!;
    setState(() {
      final lesson = lessons.removeAt(oldIndex);
      lessons.insert(newIndex, lesson);
    });

    try {
      final repository = context.read<MainRepository>();
      final lessonIds = lessons.map((l) => l.id).toList();
      await repository.reorderLessons(lessonIds);
    } catch (e) {
      await _loadContent();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إعادة الترتيب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToExamManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamManagementScreen(course: widget.course),
      ),
    );
  }
}

// حوار إضافة/تعديل الوحدة
class _ModuleDialog extends StatefulWidget {
  final String? title;
  final String? description;

  const _ModuleDialog({this.title, this.description});

  @override
  State<_ModuleDialog> createState() => _ModuleDialogState();
}

class _ModuleDialogState extends State<_ModuleDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title == null ? 'إضافة وحدة جديدة' : 'تعديل الوحدة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'عنوان الوحدة',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'الوصف (اختياري)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              Navigator.pop(context, {
                'title': _titleController.text,
                'description': _descriptionController.text,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkBlue,
            foregroundColor: AppTheme.white,
          ),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
