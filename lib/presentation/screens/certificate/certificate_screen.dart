import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/data/models/certificate/certificate_template.dart';
import 'package:course_provider/data/models/certificate/certificate_settings.dart';
import 'package:course_provider/data/models/certificate/signature_data.dart';
import 'package:course_provider/presentation/blocs/course/course_bloc.dart';
import 'package:course_provider/presentation/blocs/course/course_event.dart';
import 'widgets/mobile_template_card.dart';
import 'widgets/desktop_template_card.dart';
import 'dialogs/edit_template_dialog.dart';
import 'dialogs/issue_certificates_dialog.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  // قوالب افتراضية - يمكن للمستخدم تخصيصها
  final List<CertificateTemplate> _templates = [
    CertificateTemplate(
      id: 'default_template',
      name: 'القالب الافتراضي',
      type: 'classic',
      thumbnailPath: '',
      settings: CertificateSettings(
        institutionName: 'اسم المؤسسة',
        partnerName: 'منصة وصلة',
        programName: 'اسم البرنامج',
        signatures: [
          const SignatureData(name: 'الاسم', title: 'المنصب'),
        ],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(CourseLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
            isMobile ? AppTheme.paddingMedium : AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isMobile),
            SizedBox(
                height:
                    isMobile ? AppTheme.paddingSmall : AppTheme.paddingMedium),
            _buildTemplatesList(isMobile, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.preview),
          label: const Text('معاينة تجريبية'),
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

  Widget _buildTemplatesList(bool isMobile, bool isTablet) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        return Padding(
          padding: EdgeInsets.only(
              bottom:
                  isMobile ? AppTheme.paddingSmall : AppTheme.paddingMedium),
          child: _buildTemplateCard(template, isMobile, isTablet),
        );
      },
    );
  }

  Widget _buildTemplateCard(
      CertificateTemplate template, bool isMobile, bool isTablet) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(
            isMobile ? AppTheme.paddingMedium : AppTheme.paddingLarge),
        child: isMobile
            ? MobileTemplateCard(
                template: template,
                onEdit: () => _showEditTemplateDialog(template),
                onIssue: () => _showIssueCertificatesDialog(template),
                onToggleAutoIssue: () => _toggleAutoIssue(template),
              )
            : DesktopTemplateCard(
                template: template,
                isTablet: isTablet,
                onEdit: () => _showEditTemplateDialog(template),
                onIssue: () => _showIssueCertificatesDialog(template),
                onToggleAutoIssue: () => _toggleAutoIssue(template),
              ),
      ),
    );
  }

  void _showEditTemplateDialog(CertificateTemplate template) {
    showDialog(
      context: context,
      builder: (context) => EditTemplateDialog(
        template: template,
        onSave: (updatedTemplate) {
          setState(() {
            final index = _templates.indexWhere((t) => t.id == template.id);
            if (index != -1) {
              _templates[index] = updatedTemplate;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ القالب بنجاح'),
              backgroundColor: AppTheme.green,
            ),
          );
        },
      ),
    );
  }

  void _showIssueCertificatesDialog(CertificateTemplate template) {
    showDialog(
      context: context,
      builder: (context) => IssueCertificatesDialog(
        template: template,
        onIssue: (courseId, selectedStudents) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إصدار ${selectedStudents.length} شهادة بنجاح'),
              backgroundColor: AppTheme.green,
            ),
          );
        },
      ),
    );
  }

  void _toggleAutoIssue(CertificateTemplate template) {
    setState(() {
      final index = _templates.indexWhere((t) => t.id == template.id);
      if (index != -1) {
        _templates[index] = CertificateTemplate(
          id: template.id,
          name: template.name,
          type: template.type,
          thumbnailPath: template.thumbnailPath,
          isAutoIssueEnabled: !template.isAutoIssueEnabled,
          settings: template.settings,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          template.isAutoIssueEnabled
              ? 'تم تعطيل الإصدار التلقائي'
              : 'تم تفعيل الإصدار التلقائي',
        ),
        backgroundColor: AppTheme.blue,
      ),
    );
  }
}
