import 'package:flutter/material.dart';
import '../theme/Theme.dart';
import '../models/index.dart';
import '../utils/app_icons.dart';

class CourseCertificatesScreen extends StatefulWidget {
  final Course course;

  const CourseCertificatesScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseCertificatesScreen> createState() =>
      _CourseCertificatesScreenState();
}

class _CourseCertificatesScreenState extends State<CourseCertificatesScreen> {
  final _searchController = TextEditingController();
  List<CourseCertificate> _certificates = [];
  List<CourseCertificate> _filteredCertificates = [];
  Set<String> _selectedCertificates = {};

  @override
  void initState() {
    super.initState();
    _loadCertificates();
    _searchController.addListener(_filterCertificates);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCertificates() {
    // Mock data - في التطبيق الحقيقي، ستأتي من API
    _certificates = [
      CourseCertificate(
        id: '1',
        studentName: 'فاطمة علي',
        studentEmail: 'fatima@example.com',
        issueDate: DateTime.now().subtract(const Duration(days: 5)),
        certificateNumber: 'CERT-2024-001',
        status: CertificateStatus.issued,
        downloadCount: 3,
        grade: 'A+',
        score: 92,
      ),
      CourseCertificate(
        id: '2',
        studentName: 'أحمد محمد',
        studentEmail: 'ahmed@example.com',
        issueDate: DateTime.now().subtract(const Duration(days: 2)),
        certificateNumber: 'CERT-2024-002',
        status: CertificateStatus.pending,
        downloadCount: 0,
        grade: 'B+',
        score: 85,
      ),
      CourseCertificate(
        id: '3',
        studentName: 'سارة أحمد',
        studentEmail: 'sara@example.com',
        issueDate: DateTime.now().subtract(const Duration(days: 1)),
        certificateNumber: 'CERT-2024-003',
        status: CertificateStatus.issued,
        downloadCount: 1,
        grade: 'A',
        score: 88,
      ),
    ];
    _filteredCertificates = List.from(_certificates);
  }

  void _filterCertificates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCertificates = _certificates.where((cert) {
        return cert.studentName.toLowerCase().contains(query) ||
            cert.studentEmail.toLowerCase().contains(query) ||
            cert.certificateNumber.toLowerCase().contains(query);
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
        title: Text('شهادات كورس: ${widget.course.title}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _refreshCertificates,
            icon: const Icon(AppIcons.refresh),
            tooltip: 'تحديث القائمة',
          ),
          IconButton(
            onPressed: _showCertificateTemplate,
            icon: const Icon(AppIcons.settings),
            tooltip: 'إعدادات القالب',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndActions(),
          _buildCertificatesList(),
        ],
      ),
    );
  }

  Widget _buildSearchAndActions() {
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
                hintText: 'بحث بالاسم، البريد الإلكتروني، أو رقم الشهادة...',
                prefixIcon: Icon(AppIcons.search, color: AppTheme.darkGray),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        _selectedCertificates.isNotEmpty ? _selectAll : null,
                    icon: const Icon(AppIcons.active, size: 14),
                    label: const Text('تحديد', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blue,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed:
                        _selectedCertificates.isNotEmpty ? _bulkDownload : null,
                    icon: const Icon(AppIcons.download, size: 14),
                    label: const Text('تحميل', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: _generateNewCertificates,
                    icon: const Icon(AppIcons.add, size: 14),
                    label: const Text('إصدار', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkBlue,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesList() {
    if (_filteredCertificates.isEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredCertificates.length,
        itemBuilder: (context, index) {
          final certificate = _filteredCertificates[index];
          return _buildCertificateCard(certificate, index);
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value:
                  _selectedCertificates.length == _filteredCertificates.length,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedCertificates =
                        _filteredCertificates.map((c) => c.id).toSet();
                  } else {
                    _selectedCertificates.clear();
                  }
                });
              },
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              'الطالب',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'رقم الشهادة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'الدرجة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'تاريخ الإصدار',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'الحالة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'التحميلات',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
          const SizedBox(width: 120), // للإجراءات
        ],
      ),
    );
  }

  Widget _buildCertificateRow(CourseCertificate certificate, int index) {
    final isSelected = _selectedCertificates.contains(certificate.id);

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
                    _selectedCertificates.add(certificate.id);
                  } else {
                    _selectedCertificates.remove(certificate.id);
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate.studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkBlue,
                  ),
                ),
                Text(
                  certificate.studentEmail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkGray,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              certificate.certificateNumber,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.darkBlue,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getGradeColor(certificate.grade).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                certificate.grade,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getGradeColor(certificate.grade),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(certificate.issueDate),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.darkGray,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusBadge(certificate.status),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(
                  AppIcons.download,
                  size: 16,
                  color: AppTheme.darkGray,
                ),
                const SizedBox(width: 4),
                Text(
                  certificate.downloadCount.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkGray,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _previewCertificate(certificate),
                  icon: const Icon(AppIcons.eye, size: 18),
                  color: AppTheme.blue,
                  tooltip: 'معاينة',
                ),
                IconButton(
                  onPressed: () => _downloadCertificate(certificate),
                  icon: const Icon(AppIcons.download, size: 18),
                  color: AppTheme.green,
                  tooltip: 'تحميل',
                ),
                IconButton(
                  onPressed: () => _sendCertificate(certificate),
                  icon: const Icon(Icons.send, size: 18),
                  color: AppTheme.darkBlue,
                  tooltip: 'إرسال',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(CertificateStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case CertificateStatus.issued:
        color = AppTheme.green;
        text = 'صادرة';
        icon = AppIcons.active;
        break;
      case CertificateStatus.pending:
        color = AppTheme.yellow;
        text = 'معلقة';
        icon = AppIcons.clock;
        break;
      case CertificateStatus.revoked:
        color = AppTheme.red;
        text = 'ملغاة';
        icon = AppIcons.inactive;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
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
            AppIcons.certificates,
            size: 64,
            color: AppTheme.darkGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد شهادات صادرة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'لم يتم إصدار أي شهادات لهذا الكورس بعد',
            style: TextStyle(color: AppTheme.darkGray),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generateNewCertificates,
            icon: const Icon(AppIcons.add),
            label: const Text('إصدار شهادات جديدة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkBlue,
              foregroundColor: AppTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return AppTheme.green;
      case 'B+':
      case 'B':
        return AppTheme.blue;
      case 'C+':
      case 'C':
        return AppTheme.yellow;
      default:
        return AppTheme.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _selectAll() {
    setState(() {
      if (_selectedCertificates.length == _filteredCertificates.length) {
        _selectedCertificates.clear();
      } else {
        _selectedCertificates = _filteredCertificates.map((c) => c.id).toSet();
      }
    });
  }

  void _bulkDownload() {
    final selectedCerts = _filteredCertificates
        .where((c) => _selectedCertificates.contains(c.id))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحميل مجمع'),
        content: Text(
          'سيتم تحميل ${selectedCerts.length} شهادة في ملف مضغوط. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // تنفيذ التحميل المجمع
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('جاري تحميل ${selectedCerts.length} شهادة...'),
                  backgroundColor: AppTheme.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green),
            child: const Text('تحميل'),
          ),
        ],
      ),
    );
  }

  void _generateNewCertificates() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CertificateGenerationScreen(course: widget.course),
      ),
    );
  }

  void _previewCertificate(CourseCertificate certificate) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'معاينة الشهادة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.lightGray),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'معاينة الشهادة\n(قيد التطوير)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadCertificate(CourseCertificate certificate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري تحميل شهادة ${certificate.studentName}...'),
        backgroundColor: AppTheme.green,
      ),
    );
  }

  void _sendCertificate(CourseCertificate certificate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إرسال الشهادة'),
        content: Text(
          'سيتم إرسال الشهادة إلى ${certificate.studentEmail}. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('تم إرسال الشهادة إلى ${certificate.studentEmail}'),
                  backgroundColor: AppTheme.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _refreshCertificates() {
    setState(() {
      _loadCertificates();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث قائمة الشهادات'),
        backgroundColor: AppTheme.green,
      ),
    );
  }

  void _showCertificateTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('إعدادات قالب الشهادة - قيد التطوير'),
        backgroundColor: AppTheme.blue,
      ),
    );
  }

  Widget _buildCertificateCard(CourseCertificate certificate, int index) {
    final isSelected = _selectedCertificates.contains(certificate.id);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedCertificates.add(certificate.id);
                      } else {
                        _selectedCertificates.remove(certificate.id);
                      }
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      Text(
                        certificate.studentEmail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(certificate.status),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildCertInfoItem(
                          'رقم الشهادة',
                          certificate.certificateNumber,
                          AppIcons.document,
                        ),
                      ),
                      Expanded(
                        child: _buildCertInfoItem(
                          'الدرجة',
                          certificate.grade,
                          AppIcons.star,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCertInfoItem(
                          'تاريخ الإصدار',
                          _formatDate(certificate.issueDate),
                          AppIcons.calendar,
                        ),
                      ),
                      Expanded(
                        child: _buildCertInfoItem(
                          'التحميلات',
                          certificate.downloadCount.toString(),
                          AppIcons.download,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _previewCertificate(certificate),
                    icon: const Icon(AppIcons.eye, size: 14),
                    label: const Text('معاينة', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blue,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadCertificate(certificate),
                    icon: const Icon(AppIcons.download, size: 14),
                    label: const Text('تحميل', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendCertificate(certificate),
                    icon: const Icon(AppIcons.send, size: 14),
                    label: const Text('إرسال', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkBlue,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.darkGray),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.darkGray,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkBlue,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Models
class CourseCertificate {
  final String id;
  final String studentName;
  final String studentEmail;
  final DateTime issueDate;
  final String certificateNumber;
  final CertificateStatus status;
  final int downloadCount;
  final String grade;
  final int score;

  CourseCertificate({
    required this.id,
    required this.studentName,
    required this.studentEmail,
    required this.issueDate,
    required this.certificateNumber,
    required this.status,
    required this.downloadCount,
    required this.grade,
    required this.score,
  });
}

enum CertificateStatus { issued, pending, revoked }

// Placeholder for Certificate Generation Screen
class CertificateGenerationScreen extends StatelessWidget {
  final Course course;

  const CertificateGenerationScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إصدار شهادات جديدة'),
        backgroundColor: AppTheme.darkBlue,
        foregroundColor: AppTheme.white,
      ),
      body: const Center(
        child: Text(
          'شاشة إصدار الشهادات الجديدة\n(قيد التطوير)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.darkGray,
          ),
        ),
      ),
    );
  }
}
