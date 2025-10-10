import 'package:flutter/material.dart';
import '../theme/Theme.dart';
import '../models/index.dart';
import '../utils/app_icons.dart';

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
  int _selectedModuleIndex = 0;
  final List<CourseModule> _modules = [
    CourseModule(
      id: '1',
      title: 'مقدمة في البرمجة',
      lessons: [
        Lesson(
          id: '1',
          title: 'ما هي البرمجة؟',
          type: LessonType.video,
          duration: 15,
          videoUrl: 'https://example.com/video1',
        ),
        Lesson(
          id: '2',
          title: 'أدوات البرمجة',
          type: LessonType.video,
          duration: 20,
          videoUrl: 'https://example.com/video2',
        ),
      ],
    ),
    CourseModule(
      id: '2',
      title: 'أساسيات البرمجة',
      lessons: [
        Lesson(
          id: '3',
          title: 'المتغيرات',
          type: LessonType.video,
          duration: 25,
          videoUrl: 'https://example.com/video3',
        ),
        Lesson(
          id: '4',
          title: 'اختبار المتغيرات',
          type: LessonType.quiz,
          duration: 10,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBlue,
        foregroundColor: AppTheme.white,
        title: Text('إدارة محتوى: ${widget.course.title}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _previewCourse,
            icon: const Icon(AppIcons.eye),
            tooltip: 'معاينة الكورس',
          ),
        ],
      ),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
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
            child: ListView.builder(
              itemCount: _modules.length,
              itemBuilder: (context, index) {
                final module = _modules[index];
                final isSelected = index == _selectedModuleIndex;
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppTheme.darkBlue.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: AppTheme.darkBlue, width: 2)
                        : null,
                  ),
                  child: ListTile(
                    title: Text(
                      module.title,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? AppTheme.darkBlue : AppTheme.darkGray,
                      ),
                    ),
                    subtitle: Text('${module.lessons.length} درس'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(AppIcons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('تعديل'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(AppIcons.delete,
                                  size: 16, color: AppTheme.red),
                              SizedBox(width: 8),
                              Text('حذف',
                                  style: TextStyle(color: AppTheme.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editModule(index);
                        } else if (value == 'delete') {
                          _deleteModule(index);
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsContent() {
    if (_modules.isEmpty) {
      return _buildEmptyModulesState();
    }

    final selectedModule = _modules[_selectedModuleIndex];

    return Container(
      color: AppTheme.lightGray,
      child: Column(
        children: [
          _buildLessonsHeader(selectedModule),
          Expanded(child: _buildLessonsList(selectedModule)),
        ],
      ),
    );
  }

  Widget _buildLessonsHeader(CourseModule module) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
                '${module.lessons.length} درس',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.darkGray,
                ),
              ),
            ],
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () => _addNewLesson(module),
                    icon: const Icon(AppIcons.add, size: 14),
                    label: const Text('درس', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkBlue,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () => _addNewQuiz(module),
                    icon: const Icon(AppIcons.quiz, size: 14),
                    label: const Text('اختبار', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.yellow,
                      foregroundColor: AppTheme.darkBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsList(CourseModule module) {
    if (module.lessons.isEmpty) {
      return _buildEmptyLessonsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: module.lessons.length,
      itemBuilder: (context, index) {
        final lesson = module.lessons[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getLessonTypeColor(lesson.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getLessonTypeIcon(lesson.type),
                color: _getLessonTypeColor(lesson.type),
                size: 20,
              ),
            ),
            title: Text(
              lesson.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBlue,
              ),
            ),
            subtitle: Text(
              '${_getLessonTypeText(lesson.type)} • ${lesson.duration} دقيقة',
              style: const TextStyle(color: AppTheme.darkGray),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _editLesson(lesson),
                  icon: const Icon(AppIcons.edit, size: 18),
                  color: AppTheme.darkBlue,
                ),
                IconButton(
                  onPressed: () => _deleteLesson(module, lesson),
                  icon: const Icon(AppIcons.delete, size: 18),
                  color: AppTheme.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyModulesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.courses,
            size: 64,
            color: AppTheme.darkGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد وحدات دراسية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بإضافة وحدة دراسية جديدة',
            style: TextStyle(color: AppTheme.darkGray),
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

  Widget _buildEmptyLessonsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.video,
            size: 64,
            color: AppTheme.darkGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد دروس في هذه الوحدة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بإضافة درس جديد',
            style: TextStyle(color: AppTheme.darkGray),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _addNewLesson(_modules[_selectedModuleIndex]),
                icon: const Icon(AppIcons.add),
                label: const Text('إضافة درس'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkBlue,
                  foregroundColor: AppTheme.white,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _addNewQuiz(_modules[_selectedModuleIndex]),
                icon: const Icon(AppIcons.quiz),
                label: const Text('إضافة اختبار'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.yellow,
                  foregroundColor: AppTheme.darkBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.video:
        return AppIcons.video;
      case LessonType.text:
        return Icons.document_scanner;
      case LessonType.quiz:
        return AppIcons.quiz;
      case LessonType.file:
        return Icons.attachment;
    }
  }

  Color _getLessonTypeColor(LessonType type) {
    switch (type) {
      case LessonType.video:
        return AppTheme.blue;
      case LessonType.text:
        return AppTheme.green;
      case LessonType.quiz:
        return AppTheme.yellow;
      case LessonType.file:
        return AppTheme.darkGray;
    }
  }

  String _getLessonTypeText(LessonType type) {
    switch (type) {
      case LessonType.video:
        return 'فيديو';
      case LessonType.text:
        return 'نص';
      case LessonType.quiz:
        return 'اختبار';
      case LessonType.file:
        return 'ملف';
    }
  }

  void _addNewModule() {
    _showModuleDialog();
  }

  void _editModule(int index) {
    _showModuleDialog(module: _modules[index], index: index);
  }

  void _deleteModule(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الوحدة'),
        content: Text('هل أنت متأكد من حذف الوحدة "${_modules[index].title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _modules.removeAt(index);
                if (_selectedModuleIndex >= _modules.length) {
                  _selectedModuleIndex = _modules.length - 1;
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _addNewLesson(CourseModule module) {
    _showLessonDialog(module);
  }

  void _addNewQuiz(CourseModule module) {
    _showLessonDialog(module, isQuiz: true);
  }

  void _editLesson(Lesson lesson) {
    final module = _modules[_selectedModuleIndex];
    _showLessonDialog(module, lesson: lesson);
  }

  void _deleteLesson(CourseModule module, Lesson lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الدرس'),
        content: Text('هل أنت متأكد من حذف الدرس "${lesson.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                module.lessons.remove(lesson);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showModuleDialog({CourseModule? module, int? index}) {
    final titleController = TextEditingController(text: module?.title ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(module == null ? 'إضافة وحدة جديدة' : 'تعديل الوحدة'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'عنوان الوحدة',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  if (module == null) {
                    _modules.add(CourseModule(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      lessons: [],
                    ));
                  } else if (index != null) {
                    _modules[index] =
                        module.copyWith(title: titleController.text);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text(module == null ? 'إضافة' : 'حفظ'),
          ),
        ],
      ),
    );
  }

  void _showLessonDialog(CourseModule module,
      {Lesson? lesson, bool isQuiz = false}) {
    final titleController = TextEditingController(text: lesson?.title ?? '');
    final durationController = TextEditingController(
      text: lesson?.duration.toString() ?? '',
    );
    final videoUrlController =
        TextEditingController(text: lesson?.videoUrl ?? '');

    LessonType selectedType =
        lesson?.type ?? (isQuiz ? LessonType.quiz : LessonType.video);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(lesson == null
              ? (isQuiz ? 'إضافة اختبار جديد' : 'إضافة درس جديد')
              : 'تعديل الدرس'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الدرس',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<LessonType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'نوع الدرس',
                    border: OutlineInputBorder(),
                  ),
                  items: LessonType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getLessonTypeText(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'المدة (بالدقائق)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (selectedType == LessonType.video) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: videoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط الفيديو',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final newLesson = Lesson(
                    id: lesson?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    type: selectedType,
                    duration: int.tryParse(durationController.text) ?? 0,
                    videoUrl: selectedType == LessonType.video
                        ? videoUrlController.text
                        : null,
                  );

                  setState(() {
                    if (lesson == null) {
                      module.lessons.add(newLesson);
                    } else {
                      final index = module.lessons.indexOf(lesson);
                      if (index != -1) {
                        module.lessons[index] = newLesson;
                      }
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(lesson == null ? 'إضافة' : 'حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _previewCourse() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('معاينة الكورس - قيد التطوير')),
    );
  }

  Widget _buildModulesDropdown() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedModuleIndex,
                isExpanded: true,
                hint: const Text('اختر الوحدة الدراسية'),
                items: _modules.asMap().entries.map((entry) {
                  final index = entry.key;
                  final module = entry.value;
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(
                      '${module.title} (${module.lessons.length} درس)',
                      style: const TextStyle(fontSize: 14),
                    ),
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
    );
  }
}

// Models
class CourseModule {
  final String id;
  final String title;
  final List<Lesson> lessons;

  CourseModule({
    required this.id,
    required this.title,
    required this.lessons,
  });

  CourseModule copyWith({
    String? id,
    String? title,
    List<Lesson>? lessons,
  }) {
    return CourseModule(
      id: id ?? this.id,
      title: title ?? this.title,
      lessons: lessons ?? this.lessons,
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final LessonType type;
  final int duration;
  final String? videoUrl;

  Lesson({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    this.videoUrl,
  });
}

enum LessonType { video, text, quiz, file }
