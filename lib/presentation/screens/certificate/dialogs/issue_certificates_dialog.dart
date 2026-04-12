import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../data/models/certificate/certificate.dart';
import '../../../blocs/certificate/certificate_exports.dart';

class IssueCertificatesDialog extends StatefulWidget {
  final String courseId;
  final String providerId;
  final List<EligibleStudent> eligibleStudents;
  final CertificateSettings? settings;

  const IssueCertificatesDialog({
    super.key,
    required this.courseId,
    required this.providerId,
    required this.eligibleStudents,
    this.settings,
  });

  @override
  State<IssueCertificatesDialog> createState() =>
      _IssueCertificatesDialogState();
}

class _IssueCertificatesDialogState extends State<IssueCertificatesDialog> {
  final Set<String> _selectedStudents = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _selectAll = true;
    _selectedStudents.addAll(
      widget.eligibleStudents.map((s) => s.studentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Expanded(child: _buildContent()),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.darkBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.certificates, color: AppTheme.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'إصدار شهادات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppTheme.white),
            tooltip: 'إغلاق',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.eligibleStudents.isEmpty) {
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
              'لا يوجد طلاب مؤهلين',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لا يوجد طلاب أكملوا الكورس ونجحوا في الامتحان',
              style: TextStyle(color: AppTheme.darkGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSelectAllRow(),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.eligibleStudents.length,
            itemBuilder: (context, index) {
              final student = widget.eligibleStudents[index];
              return _buildStudentCard(student);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectAllRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppTheme.lightGray.withOpacity(0.5),
      child: Row(
        children: [
          Checkbox(
            value: _selectAll,
            onChanged: (value) {
              setState(() {
                _selectAll = value ?? false;
                if (_selectAll) {
                  _selectedStudents.addAll(
                    widget.eligibleStudents.map((s) => s.studentId),
                  );
                } else {
                  _selectedStudents.clear();
                }
              });
            },
          ),
          const SizedBox(width: 8),
          Text(
            'تحديد الكل (${widget.eligibleStudents.length} طالب)',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(EligibleStudent student) {
    final isSelected = _selectedStudents.contains(student.studentId);

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
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedStudents.add(student.studentId);
            } else {
              _selectedStudents.remove(student.studentId);
            }
            _selectAll =
                _selectedStudents.length == widget.eligibleStudents.length;
          });
        },
        title: Text(
          student.studentName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkBlue,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              student.studentEmail,
              style: const TextStyle(fontSize: 12, color: AppTheme.darkGray),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                    'التقدم', '${student.progress}%', AppTheme.green),
                const SizedBox(width: 8),
                if (student.examScore != null)
                  _buildInfoChip(
                      'الدرجة', '${student.examScore}', AppTheme.blue),
              ],
            ),
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return BlocConsumer<CertificateBloc, CertificateState>(
      listener: (context, state) {
        if (state is CertificatesIssued) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor:
                  state.failedCount == 0 ? AppTheme.green : AppTheme.yellow,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is CertificateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isIssuing = state is CertificatesIssuing;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.lightGray.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              if (isIssuing)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: state.current / state.total,
                      backgroundColor: AppTheme.lightGray,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.blue),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'جاري إصدار الشهادات... ${state.current}/${state.total}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          isIssuing ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: isIssuing || _selectedStudents.isEmpty
                          ? null
                          : _issueCertificates,
                      icon: isIssuing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.white),
                              ),
                            )
                          : const Icon(AppIcons.certificates),
                      label: Text(
                        isIssuing
                            ? 'جاري الإصدار...'
                            : 'إصدار (${_selectedStudents.length})',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkBlue,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _issueCertificates() {
    context.read<CertificateBloc>().add(
          IssueMultipleCertificates(
            courseId: widget.courseId,
            studentIds: _selectedStudents.toList(),
            providerId: widget.providerId,
            logoUrl: widget.settings?.logoUrl,
            signatureUrl: widget.settings?.signatureUrl,
            customColor: widget.settings?.customColor,
          ),
        );
  }
}
