import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_icons.dart';
import '../../data/models/course.dart';
import '../../data/models/certificate/certificate.dart';
import '../blocs/certificate/certificate_exports.dart';
import 'certificate/dialogs/issue_certificates_dialog.dart';
import 'certificate/dialogs/certificate_settings_dialog.dart';
import 'certificate_preview_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCertificates() {
    context.read<CertificateBloc>().add(
          LoadCourseCertificates(widget.course.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          backgroundColor: AppTheme.darkBlue,
          foregroundColor: AppTheme.white,
          title: Text('شهادات كورس: ${widget.course.title}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'العودة',
          ),
          actions: [
            IconButton(
              onPressed: _loadCertificates,
              icon: const Icon(AppIcons.refresh),
              tooltip: 'تحديث القائمة',
            ),
            IconButton(
              onPressed: _showSettings,
              icon: const Icon(AppIcons.settings),
              tooltip: 'إعدادات الشهادة',
            ),
          ],
        ),
        body: BlocBuilder<CertificateBloc, CertificateState>(
          builder: (context, state) {
            if (state is CertificateLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CertificateError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadCertificates,
                      icon: const Icon(AppIcons.refresh),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkBlue,
                        foregroundColor: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is CourseCertificatesLoaded) {
              return Column(
                children: [
                  _buildSearchAndActions(state),
                  Expanded(
                    child: state.filteredCertificates.isEmpty
                        ? _buildEmptyState()
                        : _buildCertificatesList(state.filteredCertificates),
                  ),
                ],
              );
            }

            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndActions(CourseCertificatesLoaded state) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText:
                        'بحث بالاسم، البريد الإلكتروني، أو رقم الشهادة...',
                    prefixIcon: Icon(AppIcons.search, color: AppTheme.darkGray),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (query) {
                    context
                        .read<CertificateBloc>()
                        .add(SearchCertificates(query));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('الكل'),
                      selected: state.statusFilter == null,
                      onSelected: (selected) {
                        if (selected) {
                          context
                              .read<CertificateBloc>()
                              .add(const FilterCertificates(status: null));
                        }
                      },
                    ),
                    FilterChip(
                      label: const Text('صادرة'),
                      selected: state.statusFilter == CertificateStatus.issued,
                      onSelected: (selected) {
                        context.read<CertificateBloc>().add(
                              FilterCertificates(
                                status:
                                    selected ? CertificateStatus.issued : null,
                              ),
                            );
                      },
                    ),
                    FilterChip(
                      label: const Text('ملغاة'),
                      selected: state.statusFilter == CertificateStatus.revoked,
                      onSelected: (selected) {
                        context.read<CertificateBloc>().add(
                              FilterCertificates(
                                status:
                                    selected ? CertificateStatus.revoked : null,
                              ),
                            );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showIssueDialog,
                icon: const Icon(AppIcons.add, size: 18),
                label: const Text('إصدار شهادات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkBlue,
                  foregroundColor: AppTheme.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesList(List<Certificate> certificates) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: certificates.length,
      itemBuilder: (context, index) {
        final certificate = certificates[index];
        return _buildCertificateCard(certificate);
      },
    );
  }

  Widget _buildCertificateCard(Certificate certificate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(height: 4),
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
                      if (certificate.grade != null)
                        Expanded(
                          child: _buildCertInfoItem(
                            'الدرجة',
                            certificate.grade!,
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
                      if (certificate.completionDate != null)
                        Expanded(
                          child: _buildCertInfoItem(
                            'تاريخ الإكمال',
                            _formatDate(certificate.completionDate!),
                            AppIcons.clock,
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
                if (certificate.status == CertificateStatus.issued)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _revokeCertificate(certificate),
                      icon: const Icon(Icons.block, size: 14),
                      label:
                          const Text('إلغاء', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.red,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _restoreCertificate(certificate),
                      icon: const Icon(Icons.restore, size: 14),
                      label:
                          const Text('استعادة', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.green,
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
      case CertificateStatus.revoked:
        color = AppTheme.red;
        text = 'ملغاة';
        icon = AppIcons.inactive;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
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
            onPressed: _showIssueDialog,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showIssueDialog() async {
    // تحميل الطلاب المؤهلين
    context.read<CertificateBloc>().add(LoadEligibleStudents(widget.course.id));

    // تحميل الإعدادات
    context
        .read<CertificateBloc>()
        .add(LoadCertificateSettings(widget.course.id));

    // الانتظار قليلاً للتحميل
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final bloc = context.read<CertificateBloc>();
    final state = bloc.state;

    List<EligibleStudent> students = [];
    CertificateSettings? settings;

    if (state is EligibleStudentsLoaded) {
      students = state.students;
    }

    // جلب الإعدادات من حالة منفصلة إذا لزم الأمر
    // يمكن تحسين هذا لاحقاً باستخدام StreamBuilder

    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: IssueCertificatesDialog(
          courseId: widget.course.id,
          providerId: widget.course.providerId,
          eligibleStudents: students,
          settings: settings,
        ),
      ),
    );
  }

  void _showSettings() async {
    context
        .read<CertificateBloc>()
        .add(LoadCertificateSettings(widget.course.id));

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final bloc = context.read<CertificateBloc>();
    final state = bloc.state;

    CertificateSettings? settings;
    if (state is CertificateSettingsLoaded) {
      settings = state.settings;
    }

    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: CertificateSettingsDialog(
          courseId: widget.course.id,
          initialSettings: settings,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadCertificates();
      }
    });
  }

  void _previewCertificate(Certificate certificate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CertificatePreviewScreen(
          certificate: certificate,
        ),
      ),
    );
  }

  void _downloadCertificate(Certificate certificate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري تحميل شهادة ${certificate.studentName}...'),
        backgroundColor: AppTheme.green,
      ),
    );
    // TODO: تنفيذ التحميل الفعلي
  }

  void _revokeCertificate(Certificate certificate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الشهادة'),
        content: Text(
          'هل أنت متأكد من إلغاء شهادة ${certificate.studentName}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<CertificateBloc>()
                  .add(RevokeCertificate(certificate.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('إلغاء الشهادة'),
          ),
        ],
      ),
    );
  }

  void _restoreCertificate(Certificate certificate) {
    context.read<CertificateBloc>().add(RestoreCertificate(certificate.id));
  }
}
