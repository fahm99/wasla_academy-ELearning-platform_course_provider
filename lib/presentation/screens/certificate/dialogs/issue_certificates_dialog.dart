import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/core/utils/app_icons.dart';
import 'package:course_provider/data/models/certificate/certificate_template.dart';
import 'package:course_provider/data/models/course.dart';
import 'package:course_provider/presentation/blocs/course/course_bloc.dart';
import 'package:course_provider/presentation/blocs/course/course_state.dart';

class IssueCertificatesDialog extends StatefulWidget {
  final CertificateTemplate template;
  final Function(String courseId, List<String> selectedStudents) onIssue;

  const IssueCertificatesDialog({
    super.key,
    required this.template,
    required this.onIssue,
  });

  @override
  State<IssueCertificatesDialog> createState() =>
      _IssueCertificatesDialogState();
}

class _IssueCertificatesDialogState extends State<IssueCertificatesDialog> {
  String? _selectedCourseId;
  final List<String> _selectedStudents = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents(String courseId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // جلب الطلاب المسجلين في الكورس والذين أكملوا 100%
      final response = await context
          .read<CourseBloc>()
          .repository
          .supabase
          .from('enrollments')
          .select('''
            student_id,
            completion_percentage,
            users!enrollments_student_id_fkey(id, name, avatar_url)
          ''')
          .eq('course_id', courseId)
          .eq('completion_percentage', 100)
          .eq('status', 'completed');

      setState(() {
        _students = (response as List).map((item) {
          final user = item['users'];
          return {
            'id': user['id'],
            'name': user['name'],
            'avatar': user['avatar_url'],
            'isCompleted': true,
            'progress': item['completion_percentage'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الطلاب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredStudents {
    return _students.where((student) {
      final matchesSearch = student['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AlertDialog(
      title: Text(
        'إصدار الشهادات',
        style: TextStyle(fontSize: isMobile ? 16 : 18),
      ),
      content: SizedBox(
        width: isMobile ? double.maxFinite : 600,
        height: isMobile ? 400 : 500,
        child: Column(
          children: [
            _buildCourseSelector(),
            SizedBox(
                height:
                    isMobile ? AppTheme.paddingSmall : AppTheme.paddingMedium),
            if (_selectedCourseId != null) ...[
              _buildSearchField(),
              SizedBox(
                  height: isMobile
                      ? AppTheme.paddingSmall
                      : AppTheme.paddingMedium),
              _buildSelectAllCheckbox(),
              const Divider(),
              _buildStudentsList(),
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
          onPressed: _selectedCourseId != null && _selectedStudents.isNotEmpty
              ? () {
                  widget.onIssue(_selectedCourseId!, _selectedStudents);
                  Navigator.pop(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkBlue,
            foregroundColor: AppTheme.white,
          ),
          child: const Text('إصدار الشهادات الآن'),
        ),
      ],
    );
  }

  Widget _buildCourseSelector() {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state is CourseLoaded) {
          final publishedCourses = state.courses
              .where((c) => c.status == CourseStatus.published)
              .toList();

          return DropdownButtonFormField<String>(
            value: _selectedCourseId,
            decoration: const InputDecoration(
              labelText: 'اختر الكورس',
            ),
            items: publishedCourses.map((course) {
              return DropdownMenuItem(
                value: course.id,
                child: Text(course.title),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCourseId = value;
                _selectedStudents.clear();
                _students.clear();
              });
              if (value != null) {
                _loadStudents(value);
              }
            },
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        labelText: 'البحث باسم الطالب',
        prefixIcon: Icon(AppIcons.search),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildSelectAllCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _selectedStudents.length == _filteredStudents.length &&
              _filteredStudents.isNotEmpty,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedStudents.clear();
                _selectedStudents.addAll(
                  _filteredStudents.map((s) => s['id'].toString()),
                );
              } else {
                _selectedStudents.clear();
              }
            });
          },
        ),
        const Text('تحديد الكل'),
        const Spacer(),
        Text(
          '${_selectedStudents.length} محدد',
          style: const TextStyle(
            color: AppTheme.darkGray,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsList() {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_filteredStudents.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: AppTheme.mediumGray,
              ),
              const SizedBox(height: 16),
              Text(
                'لا يوجد طلاب مؤهلين للحصول على الشهادة',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يجب أن يكمل الطالب 100% من الكورس',
                style: TextStyle(
                  color: AppTheme.mediumGray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _filteredStudents.length,
        itemBuilder: (context, index) {
          final student = _filteredStudents[index];
          final isSelected = _selectedStudents.contains(student['id']);

          return CheckboxListTile(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedStudents.add(student['id']);
                } else {
                  _selectedStudents.remove(student['id']);
                }
              });
            },
            secondary: CircleAvatar(
              backgroundColor: AppTheme.lightGray,
              backgroundImage: student['avatar'] != null
                  ? NetworkImage(student['avatar'])
                  : null,
              child: student['avatar'] == null
                  ? Text(
                      student['name'].toString().substring(0, 1),
                      style: const TextStyle(
                        color: AppTheme.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            title: Text(student['name']),
            subtitle: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppTheme.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'مكتمل (${student['progress']}%)',
                  style: const TextStyle(
                    color: AppTheme.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
