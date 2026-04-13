import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/core/utils/app_icons.dart';
import 'package:course_provider/data/models/course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/course/course_bloc.dart';
import '../blocs/course/course_event.dart';
import '../blocs/course/course_state.dart';
import '../widgets/course_card.dart';
import '../widgets/course_form_dialog.dart';
import 'course_content_management_screen.dart';
import 'course_students_screen.dart';
import 'course_certificates_screen.dart';
import 'exam_management_screen.dart';

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
            onManageExams: () => _navigateToExamManagement(courses[index]),
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
      builder: (context) => const CourseFormDialog(),
    );
  }

  void _showEditCourseDialog(Course course) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CourseFormDialog(course: course),
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

  void _navigateToExamManagement(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamManagementScreen(course: course),
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
