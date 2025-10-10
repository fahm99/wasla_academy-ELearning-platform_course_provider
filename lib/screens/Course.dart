import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../theme/Theme.dart';
import '../widgets/index.dart';
import '../models/index.dart';
import '../utils/app_icons.dart';
import 'course_content_management_screen.dart';
import 'course_students_screen.dart';
import 'course_certificates_screen.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'جميع التصنيفات';
  String _selectedLevel = 'جميع المستويات';
  String _selectedStatus = 'جميع الحالات';

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(CourseLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchAndFilters(),
            const SizedBox(height: 16),
            Expanded(child: _buildCoursesGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'إدارة الكورسات',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showCreateCourseDialog(),
          icon: const Icon(AppIcons.add, size: 18),
          label: const Text('إضافة كورس جديد'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkBlue,
            foregroundColor: AppTheme.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Box
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'بحث في الكورسات...',
                prefixIcon: Icon(AppIcons.search, color: AppTheme.darkGray),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                context.read<CourseBloc>().add(
                      CourseSearchRequested(query: value),
                    );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Filter Container
          Row(
            children: [
              Expanded(
                  child: _buildFilterDropdown(
                      'التصنيف', _selectedCategory, _getCategoryOptions(),
                      (value) {
                setState(() => _selectedCategory = value!);
                _applyFilters();
              })),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildFilterDropdown(
                      'المستوى', _selectedLevel, _getLevelOptions(), (value) {
                setState(() => _selectedLevel = value!);
                _applyFilters();
              })),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildFilterDropdown(
                      'الحالة', _selectedStatus, _getStatusOptions(), (value) {
                setState(() => _selectedStatus = value!);
                _applyFilters();
              })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
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

  List<String> _getCategoryOptions() {
    return ['جميع التصنيفات', 'تقنية', 'لغات', 'تنمية بشرية', 'أعمال'];
  }

  List<String> _getLevelOptions() {
    return ['جميع المستويات', 'مبتدئ', 'متوسط', 'متقدم'];
  }

  List<String> _getStatusOptions() {
    return ['جميع الحالات', 'منشور', 'مسودة', 'قيد المراجعة', 'مرفوض'];
  }

  void _applyFilters() {
    context.read<CourseBloc>().add(CourseLoadRequested());
  }

  Widget _buildCoursesGrid() {
    return BlocConsumer<CourseBloc, CourseState>(
      listener: (context, state) {
        if (state is CourseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.red,
            ),
          );
        } else if (state is CourseOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is CourseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CourseLoaded) {
          if (state.filteredCourses.isEmpty) {
            return _buildEmptyState();
          }
          return _buildCourseList(state.filteredCourses);
        }
        return const Center(child: Text('حدث خطأ في تحميل الكورسات'));
      },
    );
  }

  Widget _buildCourseList(List<Course> courses) {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: CourseCard(
            course: courses[index],
            onEdit: () => _showEditCourseDialog(courses[index]),
            onManageContent: () => _navigateToContentManagement(courses[index]),
            onViewStudents: () => _navigateToStudents(courses[index]),
            onManageCertificates: () => _navigateToCertificates(courses[index]),
            onTogglePublish: () => _togglePublishStatus(courses[index]),
            onDelete: () => _showDeleteConfirmation(courses[index]),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.school,
            size: 64,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: 20),
          Text(
            message ?? 'لا توجد كورسات',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'ابدأ بإنشاء كورسك الأول',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.darkGray.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showCreateCourseDialog(),
            icon: const Icon(Icons.add),
            label: const Text('إنشاء كورس جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.yellow,
              foregroundColor: AppTheme.darkBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCourseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCourseModal(),
    );
  }

  Widget _buildCourseModal({Course? course}) {
    final isEditing = course != null;
    final titleController = TextEditingController(text: course?.title ?? '');
    final descriptionController =
        TextEditingController(text: course?.description ?? '');
    String selectedCategory = course?.category ?? 'tech';
    String selectedLevel =
        course?.level.toString().split('.').last ?? 'beginner';

    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.9,
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  // Modal Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: AppTheme.mediumGray)),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
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
                    ),
                  ),
                  // Tab Bar
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: AppTheme.mediumGray)),
                    ),
                    child: const TabBar(
                      labelColor: AppTheme.darkBlue,
                      unselectedLabelColor: AppTheme.darkGray,
                      indicatorColor: AppTheme.yellow,
                      indicatorWeight: 3,
                      tabs: [
                        Tab(text: 'المعلومات الأساسية'),
                        Tab(text: 'المحتوى'),
                        Tab(text: 'الإعدادات'),
                      ],
                    ),
                  ),
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildBasicInfoTab(
                            titleController,
                            descriptionController,
                            selectedCategory,
                            selectedLevel,
                            setState),
                        _buildContentTab(),
                        _buildSettingsTab(),
                      ],
                    ),
                  ),
                  // Modal Footer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border:
                          Border(top: BorderSide(color: AppTheme.mediumGray)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('إلغاء'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            _saveCourse(
                                titleController.text,
                                descriptionController.text,
                                selectedCategory,
                                selectedLevel);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.yellow,
                            foregroundColor: AppTheme.darkBlue,
                          ),
                          child:
                              Text(isEditing ? 'حفظ التغييرات' : 'حفظ الكورس'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoTab(
      TextEditingController titleController,
      TextEditingController descriptionController,
      String selectedCategory,
      String selectedLevel,
      StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('عنوان الكورس',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'أدخل عنوان الكورس',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            const Text('وصف الكورس',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'أدخل وصفاً للكورس',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTab() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(
          'محتوى الكورس - قيد التطوير',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.darkGray,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(
          'إعدادات الكورس - قيد التطوير',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.darkGray,
          ),
        ),
      ),
    );
  }

  void _saveCourse(
      String title, String description, String category, String level) {
    final newCourse = Course(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      level: CourseLevel.values
          .firstWhere((e) => e.toString().split('.').last == level),
      status: CourseStatus.draft,
      isFree: true,
      providerId: 'current_user_id',
      providerName: 'Current User',
      price: 0.0,
      duration: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<CourseBloc>().add(CourseAddRequested(course: newCourse));
  }

  void _showEditCourseDialog(Course course) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCourseModal(course: course),
    );
  }

  void _showDeleteConfirmation(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الدورة'),
        content: Text('هل أنت متأكد من رغبتك في حذف دورة "${course.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CourseBloc>().add(
                    CourseDeleteRequested(courseId: course.id),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _navigateToContentManagement(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseContentManagementScreen(course: course),
      ),
    );
  }

  void _navigateToStudents(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseStudentsScreen(course: course),
      ),
    );
  }

  void _navigateToCertificates(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseCertificatesScreen(course: course),
      ),
    );
  }

  void _togglePublishStatus(Course course) {
    final newStatus = course.status == CourseStatus.published
        ? CourseStatus.draft
        : CourseStatus.published;

    final updatedCourse = course.copyWith(status: newStatus);
    context
        .read<CourseBloc>()
        .add(CourseUpdateRequested(course: updatedCourse));
  }
}
