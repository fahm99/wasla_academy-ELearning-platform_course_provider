import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/core/utils/app_icons.dart';
import 'package:course_provider/data/models/course.dart';
import 'package:course_provider/data/repositories/main_repository.dart';
import 'package:intl/intl.dart';

class CourseStudentsScreen extends StatefulWidget {
  final Course course;

  const CourseStudentsScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseStudentsScreen> createState() => _CourseStudentsScreenState();
}

class _CourseStudentsScreenState extends State<CourseStudentsScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = true;
  String _filterStatus = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = context.read<MainRepository>();
      final students =
          await repository.getCourseStudentsWithDetails(widget.course.id);

      setState(() {
        _students = students;
        _filteredStudents = students;
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

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((student) {
        final user = student['users'];
        final name = user['name'].toString().toLowerCase();
        final email = user['email'].toString().toLowerCase();
        final matchesSearch = name.contains(query) || email.contains(query);

        if (_filterStatus == 'الكل') {
          return matchesSearch;
        } else if (_filterStatus == 'مكتمل') {
          return matchesSearch && student['status'] == 'completed';
        } else if (_filterStatus == 'نشط') {
          return matchesSearch && student['status'] == 'active';
        } else if (_filterStatus == 'متوقف') {
          return matchesSearch && student['status'] == 'dropped';
        }
        return matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBlue,
        foregroundColor: AppTheme.white,
        title: Text('طلاب كورس: ${widget.course.title}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          Expanded(child: _buildStudentsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            'إجمالي الطلاب',
            _students.length.toString(),
            Icons.people,
            AppTheme.blue,
          ),
          _buildStatCard(
            'مكتمل',
            _students
                .where((s) => s['status'] == 'completed')
                .length
                .toString(),
            AppIcons.checkCircle,
            AppTheme.green,
          ),
          _buildStatCard(
            'نشط',
            _students.where((s) => s['status'] == 'active').length.toString(),
            AppIcons.clock,
            AppTheme.yellow,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.darkGray,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'بحث عن طالب...',
              prefixIcon: const Icon(AppIcons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppTheme.lightGray,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('الحالة: '),
              const SizedBox(width: 8),
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'الكل', label: Text('الكل')),
                    ButtonSegment(value: 'نشط', label: Text('نشط')),
                    ButtonSegment(value: 'مكتمل', label: Text('مكتمل')),
                    ButtonSegment(value: 'متوقف', label: Text('متوقف')),
                  ],
                  selected: {_filterStatus},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _filterStatus = newSelection.first;
                      _filterStudents();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredStudents.isEmpty) {
      return Center(
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
              'لا يوجد طلاب',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        return _buildStudentCard(_filteredStudents[index]);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> enrollment) {
    final user = enrollment['users'];
    final name = user['name'] ?? 'غير معروف';
    final email = user['email'] ?? '';
    final avatarUrl = user['avatar_url'];
    final progress = enrollment['completion_percentage'] ?? 0;
    final status = enrollment['status'] ?? 'active';
    final enrollmentDate = enrollment['enrollment_date'] != null
        ? DateTime.parse(enrollment['enrollment_date'])
        : null;
    final lastAccessed = enrollment['last_accessed'] != null
        ? DateTime.parse(enrollment['last_accessed'])
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.lightGray,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          name.substring(0, 1),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkBlue,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(status),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$progress%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(progress),
                      ),
                    ),
                    const Text(
                      'التقدم',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: AppTheme.lightGray,
              valueColor: AlwaysStoppedAnimation(_getProgressColor(progress)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (enrollmentDate != null)
                  _buildInfoChip(
                    'تاريخ التسجيل: ${DateFormat('yyyy-MM-dd').format(enrollmentDate)}',
                    Icons.calendar_today,
                  ),
                if (lastAccessed != null)
                  _buildInfoChip(
                    'آخر دخول: ${_formatLastAccess(lastAccessed)}',
                    Icons.access_time,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'completed':
        color = AppTheme.green;
        label = 'مكتمل';
        break;
      case 'active':
        color = AppTheme.blue;
        label = 'نشط';
        break;
      case 'dropped':
        color = AppTheme.red;
        label = 'متوقف';
        break;
      default:
        color = AppTheme.darkGray;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.darkGray),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.darkGray,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(int progress) {
    if (progress >= 100) return AppTheme.green;
    if (progress >= 70) return AppTheme.blue;
    if (progress >= 40) return AppTheme.yellow;
    return AppTheme.red;
  }

  String _formatLastAccess(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }
}
