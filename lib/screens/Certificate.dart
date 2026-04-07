import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../bloc/bloc.dart';
import '../theme/Theme.dart';
import '../widgets/certificate_template_widget.dart';
import '../models/index.dart';
import '../utils/app_icons.dart';

// نموذج قالب الشهادة
class CertificateTemplate {
  final String id;
  final String name;
  final String type; // 'classic' or 'modern'
  final String thumbnailPath;
  final bool isAutoIssueEnabled;
  final CertificateSettings settings;

  CertificateTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.thumbnailPath,
    this.isAutoIssueEnabled = false,
    required this.settings,
  });
}

// إعدادات الشهادة
class CertificateSettings {
  final String institutionName;
  final String partnerName;
  final String programName;
  final String certificateTitle;
  final String certificateSubtitle;
  final String certificateText;
  final List<SignatureData> signatures;
  final String sealText;
  final bool showWatermark;
  final Color primaryColor;
  final Color accentColor;
  final String? logoPath;
  final String? signaturePath;

  CertificateSettings({
    this.institutionName = 'الجامعة الوطنية',
    this.partnerName = 'منصة وصلة',
    this.programName = 'هندسة البرمجيات',
    this.certificateTitle = 'شهادة تخرج',
    this.certificateSubtitle = 'الجامعة الوطنية بالشراكة مع منصة وصلة',
    this.certificateText =
        'تمنح الجامعة الوطنية بالشراكة مع منصة وصلة التعليمية هذه الشهادة\nلتأكيد إتمام الطالب/ة المذكور/ة أدناه بنجاح متطلبات برنامج\nهندسة البرمجيات وتحقيق جميع الأكاديمية والمهارات المطلوبة',
    this.signatures = const [],
    this.sealText = 'ختم معتمد\nالجامعة الوطنية',
    this.showWatermark = true,
    this.primaryColor = const Color(0xFF0c1445),
    this.accentColor = const Color(0xFFF9D71C),
    this.logoPath,
    this.signaturePath,
  });

  CertificateSettings copyWith({
    String? institutionName,
    String? partnerName,
    String? programName,
    String? certificateTitle,
    String? certificateSubtitle,
    String? certificateText,
    List<SignatureData>? signatures,
    String? sealText,
    bool? showWatermark,
    Color? primaryColor,
    Color? accentColor,
    String? logoPath,
    String? signaturePath,
  }) {
    return CertificateSettings(
      institutionName: institutionName ?? this.institutionName,
      partnerName: partnerName ?? this.partnerName,
      programName: programName ?? this.programName,
      certificateTitle: certificateTitle ?? this.certificateTitle,
      certificateSubtitle: certificateSubtitle ?? this.certificateSubtitle,
      certificateText: certificateText ?? this.certificateText,
      signatures: signatures ?? this.signatures,
      sealText: sealText ?? this.sealText,
      showWatermark: showWatermark ?? this.showWatermark,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      logoPath: logoPath ?? this.logoPath,
      signaturePath: signaturePath ?? this.signaturePath,
    );
  }
}

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  // قوالب الشهادات الجاهزة
  final List<CertificateTemplate> _templates = [
    CertificateTemplate(
      id: 'classic_1',
      name: 'القالب الكلاسيكي',
      type: 'classic',
      thumbnailPath: 'assets/images/classic_template.png',
      settings: CertificateSettings(
        institutionName: 'الجامعة الوطنية',
        partnerName: 'منصة وصل',
        programName: 'هندسة البرمجيات',
        signatures: [
          const SignatureData(name: 'يحيى الصبري', title: 'رئيس قسم الهندسة'),
          const SignatureData(
              name: 'عبدالملك المقطري', title: 'عميد كلية الهندسة'),
          const SignatureData(
              name: 'المهندس فهمي العامري', title: 'مؤسس المنصة'),
          const SignatureData(name: 'المهندس هيكل المخلافي', title: 'المدرب'),
        ],
      ),
    ),
    CertificateTemplate(
      id: 'modern_1',
      name: 'القالب الحديث',
      type: 'modern',
      thumbnailPath: 'assets/images/modern_template.png',
      settings: CertificateSettings(
        institutionName: 'جامعة صنعاء',
        partnerName: 'أكاديمية وصل',
        programName: 'تطوير التطبيقات',
        primaryColor: const Color(0xFF1565C0),
        accentColor: const Color(0xFFFF9800),
        signatures: [
          const SignatureData(name: 'د. أحمد محمد', title: 'رئيس الجامعة'),
          const SignatureData(name: 'د. فاطمة علي', title: 'عميد الكلية'),
          const SignatureData(name: 'أ. محمد سالم', title: 'مدير الأكاديمية'),
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
                height: isMobile
                    ? AppTheme.paddingSmall
                    : AppTheme.paddingMedium), // Reduced spacing
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
            backgroundColor: AppTheme.darkBlue, // Changed to dark blue
            foregroundColor: AppTheme.white, // Changed to white
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
            ? _buildMobileTemplateCard(template)
            : _buildDesktopTemplateCard(template, isTablet),
      ),
    );
  }

  Widget _buildMobileTemplateCard(CertificateTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // معاينة مصغرة للقالب
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: AppTheme.mediumGray),
          ),
          child: const Icon(
            AppIcons.certificates,
            size: 40,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),

        // معلومات القالب
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              template.type == 'classic' ? 'قالب كلاسيكي' : 'قالب حديث',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  template.isAutoIssueEnabled
                      ? AppIcons.checkCircle
                      : AppIcons.clock,
                  size: 14,
                  color: template.isAutoIssueEnabled
                      ? AppTheme.green
                      : AppTheme.yellow,
                ),
                const SizedBox(width: 4),
                Text(
                  template.isAutoIssueEnabled
                      ? 'الإصدار التلقائي مفعل'
                      : 'الإصدار التلقائي معطل',
                  style: TextStyle(
                    fontSize: 10,
                    color: template.isAutoIssueEnabled
                        ? AppTheme.green
                        : AppTheme.yellow,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingMedium),

        // أزرار التحكم
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // زر تحرير القالب
            ElevatedButton.icon(
              onPressed: () => _showEditTemplateDialog(template),
              icon: const Icon(AppIcons.edit,
                  size: 14, color: AppTheme.yellow), // Gold icon
              label: const Text('تحرير'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBlue, // Blue background
                foregroundColor: AppTheme.white, // White text
                minimumSize: const Size(80, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            // زر إصدار الشهادات
            ElevatedButton.icon(
              onPressed: () => _showIssueCertificatesDialog(template),
              icon: const Icon(AppIcons.certificates,
                  size: 14, color: AppTheme.yellow), // Gold icon
              label: const Text('إصدار'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBlue, // Blue background
                foregroundColor: AppTheme.white, // White text
                minimumSize: const Size(80, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            // زر تفعيل الإصدار التلقائي
            ElevatedButton.icon(
              onPressed: () => _toggleAutoIssue(template),
              icon: Icon(
                template.isAutoIssueEnabled
                    ? AppIcons.toggleOn
                    : AppIcons.toggleOff,
                size: 14,
                color: AppTheme.yellow, // Gold icon
              ),
              label: Text(template.isAutoIssueEnabled ? 'تعطيل' : 'تفعيل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBlue, // Blue background
                foregroundColor: AppTheme.white, // White text
                minimumSize: const Size(80, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopTemplateCard(
      CertificateTemplate template, bool isTablet) {
    return Row(
      children: [
        // معاينة مصغرة للقالب
        Container(
          width: isTablet ? 100 : 120,
          height: isTablet ? 70 : 80,
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: AppTheme.mediumGray),
          ),
          child: const Icon(
            AppIcons.certificates,
            size: 40,
            color: AppTheme.darkGray,
          ),
        ),
        SizedBox(
            width: isTablet ? AppTheme.paddingMedium : AppTheme.paddingLarge),

        // معلومات القالب
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                template.name,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                template.type == 'classic' ? 'قالب كلاسيكي' : 'قالب حديث',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    template.isAutoIssueEnabled
                        ? AppIcons.checkCircle
                        : AppIcons.clock,
                    size: 16,
                    color: template.isAutoIssueEnabled
                        ? AppTheme.green
                        : AppTheme.yellow,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    template.isAutoIssueEnabled
                        ? 'الإصدار التلقائي مفعل'
                        : 'الإصدار التلقائي معطل',
                    style: TextStyle(
                      fontSize: 12,
                      color: template.isAutoIssueEnabled
                          ? AppTheme.green
                          : AppTheme.yellow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // أزرار التحكم
        Column(
          children: [
            // زر تحرير القالب
            ElevatedButton.icon(
              onPressed: () => _showEditTemplateDialog(template),
              icon: const Icon(AppIcons.edit,
                  size: 16, color: AppTheme.yellow), // Gold icon
              label: const Text('تحرير'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBlue, // Blue background
                foregroundColor: AppTheme.white, // White text
                minimumSize: const Size(100, 36),
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),

            // زر إصدار الشهادات
            ElevatedButton.icon(
              onPressed: () => _showIssueCertificatesDialog(template),
              icon: const Icon(AppIcons.certificates,
                  size: 16, color: AppTheme.yellow), // Gold icon
              label: const Text('إصدار'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBlue, // Blue background
                foregroundColor: AppTheme.white, // White text
                minimumSize: const Size(100, 36),
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),

            // زر تفعيل الإصدار التلقائي
            ElevatedButton.icon(
              onPressed: () => _toggleAutoIssue(template),
              icon: Icon(
                template.isAutoIssueEnabled
                    ? AppIcons.toggleOn
                    : AppIcons.toggleOff,
                size: 16,
                color: AppTheme.yellow, // Gold icon
              ),
              label: Text(template.isAutoIssueEnabled ? 'تعطيل' : 'تفعيل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBlue, // Blue background
                foregroundColor: AppTheme.white, // White text
                minimumSize: const Size(100, 36),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // حوار تحرير القالب
  void _showEditTemplateDialog(CertificateTemplate template) {
    showDialog(
      context: context,
      builder: (context) => _EditTemplateDialog(
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

  // حوار إصدار الشهادات
  void _showIssueCertificatesDialog(CertificateTemplate template) {
    showDialog(
      context: context,
      builder: (context) => _IssueCertificatesDialog(
        template: template,
        onIssue: (courseId, selectedStudents) {
          // منطق إصدار الشهادات
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

  // تفعيل/تعطيل الإصدار التلقائي
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

// حوار تحرير القالب
class _EditTemplateDialog extends StatefulWidget {
  final CertificateTemplate template;
  final Function(CertificateTemplate) onSave;

  const _EditTemplateDialog({
    required this.template,
    required this.onSave,
  });

  @override
  State<_EditTemplateDialog> createState() => _EditTemplateDialogState();
}

class _EditTemplateDialogState extends State<_EditTemplateDialog> {
  late TextEditingController _templateNameController;
  late TextEditingController _institutionNameController;
  late TextEditingController _partnerNameController;
  late TextEditingController _programNameController;
  late TextEditingController _certificateTitleController;
  late TextEditingController _certificateSubtitleController;
  late TextEditingController _certificateTextController;
  late TextEditingController _sealTextController;

  String? _selectedCourseId;
  bool _showWatermark = true;
  Color _primaryColor = const Color(0xFF0c1445);
  Color _accentColor = const Color(0xFFF9D71C);
  List<SignatureData> _signatures = [];

  @override
  void initState() {
    super.initState();
    _templateNameController = TextEditingController(text: widget.template.name);
    _institutionNameController =
        TextEditingController(text: widget.template.settings.institutionName);
    _partnerNameController =
        TextEditingController(text: widget.template.settings.partnerName);
    _programNameController =
        TextEditingController(text: widget.template.settings.programName);
    _certificateTitleController =
        TextEditingController(text: widget.template.settings.certificateTitle);
    _certificateSubtitleController = TextEditingController(
        text: widget.template.settings.certificateSubtitle);
    _certificateTextController =
        TextEditingController(text: widget.template.settings.certificateText);
    _sealTextController =
        TextEditingController(text: widget.template.settings.sealText);

    _showWatermark = widget.template.settings.showWatermark;
    _primaryColor = widget.template.settings.primaryColor;
    _accentColor = widget.template.settings.accentColor;
    _signatures = List.from(widget.template.settings.signatures);
  }

  @override
  void dispose() {
    _templateNameController.dispose();
    _institutionNameController.dispose();
    _partnerNameController.dispose();
    _programNameController.dispose();
    _certificateTitleController.dispose();
    _certificateSubtitleController.dispose();
    _certificateTextController.dispose();
    _sealTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AlertDialog(
      title: Text(
        'تحرير ${widget.template.name}',
        style: TextStyle(fontSize: isMobile ? 16 : 18),
      ),
      content: SizedBox(
        width: isMobile ? double.maxFinite : 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // اسم القالب
              TextField(
                controller: _templateNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم القالب',
                  hintText: 'مثال: شهادة دورة Flutter',
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // اسم المؤسسة
              TextField(
                controller: _institutionNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المؤسسة',
                  hintText: 'مثال: الجامعة الوطنية',
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // اسم الشريك
              TextField(
                controller: _partnerNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الشريك',
                  hintText: 'مثال: منصة وصل',
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // اسم البرنامج
              TextField(
                controller: _programNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم البرنامج',
                  hintText: 'مثال: هندسة البرمجيات',
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // عنوان الشهادة
              TextField(
                controller: _certificateTitleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الشهادة',
                  hintText: 'مثال: شهادة تخرج',
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // العنوان الفرعي
              TextField(
                controller: _certificateSubtitleController,
                decoration: const InputDecoration(
                  labelText: 'العنوان الفرعي',
                  hintText: 'مثال: الجامعة الوطنية بالشراكة مع منصة وصل',
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // نص الشهادة
              TextField(
                controller: _certificateTextController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'نص الشهادة',
                  hintText: 'النص الذي يظهر في الشهادة...',
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // نص الختم
              TextField(
                controller: _sealTextController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'نص الختم',
                  hintText: 'مثال: ختم معتمد\\nالجامعة الوطنية',
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // إظهار العلامة المائية
              SwitchListTile(
                title: const Text('إظهار العلامة المائية'),
                value: _showWatermark,
                onChanged: (value) {
                  setState(() {
                    _showWatermark = value;
                  });
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // اختيار الألوان
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('اللون الأساسي'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showColorPicker(true),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _primaryColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.mediumGray),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('اللون الثانوي'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showColorPicker(false),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _accentColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.mediumGray),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // إدارة التوقيعات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'التوقيعات',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addSignature,
                    icon: const Icon(Icons.add,
                        color: AppTheme.yellow), // Gold icon
                    label: const Text('إضافة توقيع'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkBlue, // Blue background
                      foregroundColor: AppTheme.white, // White text
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // قائمة التوقيعات
              ..._signatures.asMap().entries.map((entry) {
                final index = entry.key;
                final signature = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(signature.name),
                    subtitle: Text(signature.title),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeSignature(index),
                    ),
                    onTap: () => _editSignature(index),
                  ),
                );
              }),
              const SizedBox(height: AppTheme.paddingMedium),

              // أزرار رفع الملفات
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // منطق رفع الشعار
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('رفع الشعار')),
                        );
                      },
                      icon: const Icon(AppIcons.image,
                          color: AppTheme.yellow), // Gold icon
                      label: const Text('رفع الشعار'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkBlue, // Blue background
                        foregroundColor: AppTheme.white, // White text
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // منطق رفع التوقيع
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('رفع التوقيع')),
                        );
                      },
                      icon: const Icon(AppIcons.edit,
                          color: AppTheme.yellow), // Gold icon
                      label: const Text('رفع التوقيع'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkBlue, // Blue background
                        foregroundColor: AppTheme.white, // White text
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // زر معاينة القالب
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // منطق معاينة القالب
                    _showTemplatePreview();
                  },
                  icon: const Icon(AppIcons.eye,
                      color:
                          AppTheme.darkBlue), // Blue icon for outlined button
                  label: const Text('معاينة القالب'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.darkBlue, // Blue text
                    side: const BorderSide(
                        color: AppTheme.darkBlue), // Blue border
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedSettings = widget.template.settings.copyWith(
              institutionName: _institutionNameController.text,
              partnerName: _partnerNameController.text,
              programName: _programNameController.text,
              certificateTitle: _certificateTitleController.text,
              certificateSubtitle: _certificateSubtitleController.text,
              certificateText: _certificateTextController.text,
              sealText: _sealTextController.text,
              showWatermark: _showWatermark,
              primaryColor: _primaryColor,
              accentColor: _accentColor,
              signatures: _signatures,
            );

            final updatedTemplate = CertificateTemplate(
              id: widget.template.id,
              name: _templateNameController.text,
              type: widget.template.type,
              thumbnailPath: widget.template.thumbnailPath,
              isAutoIssueEnabled: widget.template.isAutoIssueEnabled,
              settings: updatedSettings,
            );

            widget.onSave(updatedTemplate);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkBlue, // Blue background
            foregroundColor: AppTheme.white, // White text
          ),
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  void _showTemplatePreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 00.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              // شريط العنوان
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.darkBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'معاينة القالب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // محتوى المعاينة
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Transform.scale(
                    scale: 0.7,
                    child: CertificateTemplateWidget(
                      studentName: 'اسم الطالب التجريبي',
                      specialization: widget.template.settings.programName,
                      certificateId: 'CERT-2024-001',
                      issueDate: '2024/12/07',
                      institutionName:
                          _institutionNameController.text.isNotEmpty
                              ? _institutionNameController.text
                              : widget.template.settings.institutionName,
                      partnerName: _partnerNameController.text.isNotEmpty
                          ? _partnerNameController.text
                          : widget.template.settings.partnerName,
                      programName: _programNameController.text.isNotEmpty
                          ? _programNameController.text
                          : widget.template.settings.programName,
                      certificateTitle:
                          _certificateTitleController.text.isNotEmpty
                              ? _certificateTitleController.text
                              : widget.template.settings.certificateTitle,
                      certificateSubtitle:
                          _certificateSubtitleController.text.isNotEmpty
                              ? _certificateSubtitleController.text
                              : widget.template.settings.certificateSubtitle,
                      certificateText:
                          _certificateTextController.text.isNotEmpty
                              ? _certificateTextController.text
                              : widget.template.settings.certificateText,
                      signatures: _signatures.isNotEmpty
                          ? _signatures
                          : widget.template.settings.signatures,
                      sealText: _sealTextController.text.isNotEmpty
                          ? _sealTextController.text
                          : widget.template.settings.sealText,
                      showWatermark: _showWatermark,
                      primaryColor: _primaryColor,
                      accentColor: _accentColor,
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

  void _showColorPicker(bool isPrimary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPrimary ? 'اختر اللون الأساسي' : 'اختر اللون الثانوي'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: isPrimary ? _primaryColor : _accentColor,
            onColorChanged: (color) {
              setState(() {
                if (isPrimary) {
                  _primaryColor = color;
                } else {
                  _accentColor = color;
                }
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

  void _addSignature() {
    showDialog(
      context: context,
      builder: (context) => _SignatureDialog(
        onSave: (signature) {
          setState(() {
            _signatures.add(signature);
          });
        },
      ),
    );
  }

  void _editSignature(int index) {
    showDialog(
      context: context,
      builder: (context) => _SignatureDialog(
        signature: _signatures[index],
        onSave: (signature) {
          setState(() {
            _signatures[index] = signature;
          });
        },
      ),
    );
  }

  void _removeSignature(int index) {
    setState(() {
      _signatures.removeAt(index);
    });
  }
}

// حوار إضافة/تحرير التوقيع
class _SignatureDialog extends StatefulWidget {
  final SignatureData? signature;
  final Function(SignatureData) onSave;

  const _SignatureDialog({
    this.signature,
    required this.onSave,
  });

  @override
  _SignatureDialogState createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<_SignatureDialog> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.signature?.name ?? '');
    _titleController =
        TextEditingController(text: widget.signature?.title ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.signature == null ? 'إضافة توقيع' : 'تحرير التوقيع'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'اسم الموقع',
              hintText: 'مثال: د. أحمد محمد',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'المنصب',
              hintText: 'مثال: عميد الكلية',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _titleController.text.isNotEmpty) {
              widget.onSave(SignatureData(
                name: _nameController.text,
                title: _titleController.text,
              ));
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkBlue, // Blue background
            foregroundColor: AppTheme.white, // White text
          ),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

// حوار إصدار الشهادات
class _IssueCertificatesDialog extends StatefulWidget {
  final CertificateTemplate template;
  final Function(String courseId, List<String> selectedStudents) onIssue;

  const _IssueCertificatesDialog({
    required this.template,
    required this.onIssue,
  });

  @override
  State<_IssueCertificatesDialog> createState() =>
      _IssueCertificatesDialogState();
}

class _IssueCertificatesDialogState extends State<_IssueCertificatesDialog> {
  String? _selectedCourseId;
  final List<String> _selectedStudents = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // بيانات وهمية للطلاب
  final List<Map<String, dynamic>> _mockStudents = [
    {
      'id': '1',
      'name': 'أحمد محمد علي',
      'avatar': null,
      'isCompleted': true,
      'progress': 100,
    },
    {
      'id': '2',
      'name': 'فاطمة أحمد سالم',
      'avatar': null,
      'isCompleted': true,
      'progress': 100,
    },
    {
      'id': '3',
      'name': 'محمد عبدالله حسن',
      'avatar': null,
      'isCompleted': false,
      'progress': 75,
    },
    {
      'id': '4',
      'name': 'نور الهدى يحيى',
      'avatar': null,
      'isCompleted': true,
      'progress': 100,
    },
    {
      'id': '5',
      'name': 'علي سعيد أحمد',
      'avatar': null,
      'isCompleted': true,
      'progress': 100,
    },
    {
      'id': '6',
      'name': 'مريم خالد عمر',
      'avatar': null,
      'isCompleted': false,
      'progress': 60,
    },
  ];

  List<Map<String, dynamic>> get _filteredStudents {
    return _mockStudents.where((student) {
      final matchesSearch = student['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchesSearch && student['isCompleted'] == true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AlertDialog(
      title: Text(
        ' выпуск الشهادات',
        style: TextStyle(fontSize: isMobile ? 16 : 18),
      ),
      content: SizedBox(
        width: isMobile ? double.maxFinite : 600,
        height: isMobile ? 400 : 500,
        child: Column(
          children: [
            // اختيار الكورس
            BlocBuilder<CourseBloc, CourseState>(
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
                      });
                    },
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            SizedBox(
                height:
                    isMobile ? AppTheme.paddingSmall : AppTheme.paddingMedium),

            if (_selectedCourseId != null) ...[
              // شريط البحث
              TextField(
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
              ),
              SizedBox(
                  height: isMobile
                      ? AppTheme.paddingSmall
                      : AppTheme.paddingMedium),

              // زر تحديد الكل
              Row(
                children: [
                  Checkbox(
                    value:
                        _selectedStudents.length == _filteredStudents.length &&
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
              ),
              const Divider(),

              // قائمة الطلاب
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = _filteredStudents[index];
                    final isSelected =
                        _selectedStudents.contains(student['id']);

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
                        child: Text(
                          student['name'].toString().substring(0, 1),
                          style: const TextStyle(
                            color: AppTheme.darkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(student['name']),
                      subtitle: Row(
                        children: [
                          const Icon(
                            Icons.check,
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
          onPressed: _selectedCourseId != null && _selectedStudents.isNotEmpty
              ? () {
                  widget.onIssue(_selectedCourseId!, _selectedStudents);
                  Navigator.pop(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkBlue, // Blue background
            foregroundColor: AppTheme.white, // White text
          ),
          child: const Text(' выпуск الشهادات الآن'),
        ),
      ],
    );
  }
}
