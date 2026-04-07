import 'package:flutter/material.dart';
import '../theme/Theme.dart';
import '../data/models/index.dart';
import '../utils/app_icons.dart';

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
  List<CourseStudent> _students = [];
  List<CourseStudent> _filteredStudents = [];
  Set<String> _selectedStudents = {};

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

  void _loadStudents() {
    // Mock data - في التطبيق الحقيقي، ستأتي من API
    _students = [
      CourseStudent(
        id: '1',
        name: 'أحمد محمد',
        email: 'ahmed@example.com',
        avatar: 'https://via.placeholder.com/50',
        progress: 75,
        quizScore: 85,
        certificateIssued: false,
        lastAccess: DateTime.now().subtract(const Duration(hours: 2)),
        enrollmentDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      CourseStudent(
        id: '2',
        name: 'فاطمة علي',
        email: 'fatima@example.com',
        avatar: 'https://via.placeholder.com/50',
        progress: 100,
        quizScore: 92,
        certificateIssued: true,
        lastAccess: DateTime.now().subtract(const Duration(hours: 1)),
        enrollmentDate: DateTime.now().subtract(const Duration(days: 25)),
      ),
      CourseStudent(
        id: '3',
        name: 'محمد سالم',
        email: 'mohammed@example.com',
        avatar: 'https://via.placeholder.com/50',
        progress: 45,
        quizScore: 70,
        certificateIssued: false,
        lastAccess: DateTime.now().subtract(const Duration(days: 1)),
        enrollmentDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
    _filteredStudents = List.from(_students);
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((student) {
        return student.name.toLowerCase().contains(query) ||
            student.email.toLowerCase().contains(query);
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
            onPressed: _refreshStudents,
            icon: const Icon(AppIcons.refresh),
            tooltip: 'تحديث القائمة',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildStudentsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'بحث باسم الطالب أو البريد الإلكتروني...',
                prefixIcon: Icon(AppIcons.search, color: AppTheme.darkGray),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _selectedStudents.isNotEmpty ? _selectAll : null,
                icon: const Icon(AppIcons.active, size: 16),
                label: const Text('تحديد الكل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkBlue,
                  foregroundColor: AppTheme.white,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed:
                    _selectedStudents.isNotEmpty ? _issueCertificates : null,
                icon: const Icon(AppIcons.certificates, size: 16),
                label: const Text('إصدار شهادات'),
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

  Widget _buildStudentsList() {
    if (_filteredStudents.isEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredStudents.length,
        itemBuilder: (context, index) {
          final student = _filteredStudents[index];
          return _buildStudentCard(student, index);
        },
      ),
    );
  }

  Widget _buildStudentRow(CourseStudent student, int index) {
    final isSelected = _selectedStudents.contains(student.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: index % 2 == 0
            ? AppTheme.white
            : AppTheme.lightGray.withOpacity(0.3),
        border: const Border(
          bottom: BorderSide(color: AppTheme.lightGray),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedStudents.add(student.id);
                  } else {
                    _selectedStudents.remove(student.id);
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(student.avatar),
                  onBackgroundImageError: (_, __) {},
                  child: student.avatar.isEmpty
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      Text(
                        student.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${student.progress}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: student.progress / 100,
                  backgroundColor: AppTheme.lightGray,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    student.progress == 100 ? AppTheme.green : AppTheme.blue,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getScoreColor(student.quizScore).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${student.quizScore}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(student.quizScore),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatLastAccess(student.lastAccess),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.darkGray,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(
              student.certificateIssued ? AppIcons.active : AppIcons.inactive,
              color: student.certificateIssued
                  ? AppTheme.green
                  : AppTheme.darkGray,
              size: 20,
            ),
          ),
          SizedBox(
            width: 80,
            child: IconButton(
              onPressed: () => _showStudentDetails(student),
              icon: const Icon(AppIcons.eye),
              color: AppTheme.darkBlue,
              tooltip: 'عرض التفاصيل',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.students,
            size: 64,
            color: AppTheme.darkGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا يوجد طلاب مسجلين',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'لم يسجل أي طالب في هذا الكورس بعد',
            style: TextStyle(color: AppTheme.darkGray),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppTheme.green;
    if (score >= 70) return AppTheme.yellow;
    return AppTheme.red;
  }

  String _formatLastAccess(DateTime lastAccess) {
    final now = DateTime.now();
    final difference = now.difference(lastAccess);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  void _selectAll() {
    setState(() {
      if (_selectedStudents.length == _filteredStudents.length) {
        _selectedStudents.clear();
      } else {
        _selectedStudents = _filteredStudents.map((s) => s.id).toSet();
      }
    });
  }

  void _issueCertificates() {
    final eligibleStudents = _filteredStudents
        .where((s) => _selectedStudents.contains(s.id) && s.progress == 100)
        .toList();

    if (eligibleStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد طلاب مؤهلين لإصدار الشهادات'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إصدار الشهادات'),
        content: Text(
          'سيتم إصدار ${eligibleStudents.length} شهادة للطلاب المؤهلين. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // إصدار الشهادات
              setState(() {
                for (final student in eligibleStudents) {
                  final index = _students.indexWhere((s) => s.id == student.id);
                  if (index != -1) {
                    _students[index] =
                        student.copyWith(certificateIssued: true);
                  }
                }
                _selectedStudents.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('تم إصدار ${eligibleStudents.length} شهادة بنجاح'),
                  backgroundColor: AppTheme.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green),
            child: const Text('إصدار'),
          ),
        ],
      ),
    );
  }

  void _refreshStudents() {
    setState(() {
      _loadStudents();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث قائمة الطلاب'),
        backgroundColor: AppTheme.green,
      ),
    );
  }

  void _showStudentDetails(CourseStudent student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الطالب: ${student.name}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('البريد الإلكتروني', student.email),
              _buildDetailRow('نسبة الإكمال', '${student.progress}%'),
              _buildDetailRow('نتيجة الاختبار', '${student.quizScore}%'),
              _buildDetailRow(
                  'تاريخ التسجيل', _formatDate(student.enrollmentDate)),
              _buildDetailRow(
                  'آخر دخول', _formatLastAccess(student.lastAccess)),
              _buildDetailRow('حالة الشهادة',
                  student.certificateIssued ? 'صادرة' : 'غير صادرة'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.darkGray),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStudentCard(CourseStudent student, int index) {
    final isSelected = _selectedStudents.contains(student.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.blue : AppTheme.lightGray,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedStudents.add(student.id);
                      } else {
                        _selectedStudents.remove(student.id);
                      }
                    });
                  },
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(student.avatar),
                  onBackgroundImageError: (_, __) {},
                  child: student.avatar.isEmpty
                      ? const Icon(Icons.person, size: 25)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      Text(
                        student.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showStudentDetails(student),
                  icon: const Icon(AppIcons.eye),
                  color: AppTheme.darkBlue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'نسبة الإكمال',
                    '${student.progress}%',
                    AppIcons.active,
                    student.progress == 100 ? AppTheme.green : AppTheme.blue,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'النتيجة',
                    '${student.quizScore}%',
                    AppIcons.star,
                    _getScoreColor(student.quizScore),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                const Text(
                  'نسبة الإكمال',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: student.progress / 100,
                  backgroundColor: AppTheme.lightGray,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    student.progress == 100 ? AppTheme.green : AppTheme.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      AppIcons.clock,
                      size: 16,
                      color: AppTheme.darkGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatLastAccess(student.lastAccess),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      student.certificateIssued
                          ? AppIcons.active
                          : AppIcons.inactive,
                      color: student.certificateIssued
                          ? AppTheme.green
                          : AppTheme.darkGray,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      student.certificateIssued
                          ? 'شهادة صادرة'
                          : 'لا توجد شهادة',
                      style: TextStyle(
                        fontSize: 12,
                        color: student.certificateIssued
                            ? AppTheme.green
                            : AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Model
class CourseStudent {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final int progress;
  final int quizScore;
  final bool certificateIssued;
  final DateTime lastAccess;
  final DateTime enrollmentDate;

  CourseStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.progress,
    required this.quizScore,
    required this.certificateIssued,
    required this.lastAccess,
    required this.enrollmentDate,
  });

  CourseStudent copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    int? progress,
    int? quizScore,
    bool? certificateIssued,
    DateTime? lastAccess,
    DateTime? enrollmentDate,
  }) {
    return CourseStudent(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      progress: progress ?? this.progress,
      quizScore: quizScore ?? this.quizScore,
      certificateIssued: certificateIssued ?? this.certificateIssued,
      lastAccess: lastAccess ?? this.lastAccess,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
    );
  }
}
