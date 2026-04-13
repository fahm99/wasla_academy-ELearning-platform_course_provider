import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/certificate/certificate_template.dart';
import '../../../data/repositories/main_repository.dart';
import 'certificate_preview_widget.dart';

class CertificateTemplateEditorScreen extends StatefulWidget {
  final CertificateTemplate? template;
  final String? courseId;

  const CertificateTemplateEditorScreen({
    super.key,
    this.template,
    this.courseId,
  });

  @override
  State<CertificateTemplateEditorScreen> createState() =>
      _CertificateTemplateEditorScreenState();
}

class _CertificateTemplateEditorScreenState
    extends State<CertificateTemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _headerController;
  late TextEditingController _bodyController;
  late TextEditingController _footerController;

  Color _primaryColor = const Color(0xFF1E3A8A);
  Color _secondaryColor = const Color(0xFFFCD34D);
  String? _logoUrl;
  String? _signatureUrl;
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _headerController = TextEditingController(
        text: widget.template?.templateData.headerText ?? 'شهادة إتمام');
    _bodyController = TextEditingController(
        text: widget.template?.templateData.bodyText ??
            'نشهد بأن {{student_name}} قد أكمل بنجاح الدورة التدريبية {{course_name}}');
    _footerController = TextEditingController(
        text: widget.template?.templateData.footerText ??
            'تاريخ الإصدار: {{completion_date}}');

    if (widget.template != null) {
      _primaryColor = _parseColor(widget.template!.templateData.primaryColor);
      _secondaryColor =
          _parseColor(widget.template!.templateData.secondaryColor);
      _logoUrl = widget.template!.templateData.logoUrl;
      _signatureUrl = widget.template!.templateData.signatureUrl;
      _isDefault = widget.template!.isDefault;
    }
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headerController.dispose();
    _bodyController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = context.read<MainRepository>();
      final user = await repository.getUser();

      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      final templateData = TemplateData(
        primaryColor: _colorToHex(_primaryColor),
        secondaryColor: _colorToHex(_secondaryColor),
        logoUrl: _logoUrl,
        signatureUrl: _signatureUrl,
        headerText: _headerController.text,
        bodyText: _bodyController.text,
        footerText: _footerController.text,
      );

      final template = CertificateTemplate(
        id: widget.template?.id ?? '',
        providerId: user.id,
        courseId: widget.courseId,
        name: _nameController.text,
        isDefault: _isDefault,
        templateData: templateData,
        createdAt: widget.template?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = widget.template == null
          ? await repository.createCertificateTemplate(template)
          : await repository.updateCertificateTemplate(template);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ القالب بنجاح'),
            backgroundColor: AppTheme.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBlue,
        foregroundColor: AppTheme.white,
        title: Text(widget.template == null ? 'قالب جديد' : 'تعديل القالب'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppTheme.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _saveTemplate,
              icon: const Icon(Icons.save),
              tooltip: 'حفظ',
            ),
        ],
      ),
      body: Row(
        children: [
          // محرر القالب
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfo(),
                    const SizedBox(height: 20),
                    _buildColorSection(),
                    const SizedBox(height: 20),
                    _buildTextSection(),
                    const SizedBox(height: 20),
                    _buildMediaSection(),
                    const SizedBox(height: 20),
                    _buildVariablesHelp(),
                  ],
                ),
              ),
            ),
          ),
          // معاينة مباشرة
          Expanded(
            flex: 3,
            child: Container(
              color: AppTheme.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'معاينة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: CertificatePreviewWidget(
                      templateData: TemplateData(
                        primaryColor: _colorToHex(_primaryColor),
                        secondaryColor: _colorToHex(_secondaryColor),
                        logoUrl: _logoUrl,
                        signatureUrl: _signatureUrl,
                        headerText: _headerController.text,
                        bodyText: _bodyController.text,
                        footerText: _footerController.text,
                      ),
                      studentName: 'محمد أحمد',
                      courseName: 'دورة تطوير تطبيقات Flutter',
                      completionDate: DateTime.now(),
                      providerName: 'الأكاديمية التقنية',
                      certificateNumber: 'WAS-123456',
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

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات أساسية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم القالب',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم القالب';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('تعيين كقالب افتراضي'),
              subtitle: const Text('سيتم استخدامه تلقائياً عند إصدار الشهادات'),
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الألوان',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildColorPicker(
                    'اللون الأساسي',
                    _primaryColor,
                    (color) => setState(() => _primaryColor = color),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildColorPicker(
                    'اللون الثانوي',
                    _secondaryColor,
                    (color) => setState(() => _secondaryColor = color),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(
      String label, Color color, Function(Color) onColorChanged) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(label),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: color,
                onColorChanged: onColorChanged,
                pickerAreaHeightPercent: 0.8,
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
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.mediumGray),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.mediumGray),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  Text(
                    _colorToHex(color),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'النصوص',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _headerController,
              decoration: const InputDecoration(
                labelText: 'نص الرأس',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'نص المحتوى',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _footerController,
              decoration: const InputDecoration(
                labelText: 'نص التذييل',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الوسائط',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            _buildMediaUpload(
              'الشعار',
              _logoUrl,
              (url) => setState(() => _logoUrl = url),
            ),
            const SizedBox(height: 16),
            _buildMediaUpload(
              'التوقيع',
              _signatureUrl,
              (url) => setState(() => _signatureUrl = url),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaUpload(
      String label, String? url, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        if (url != null) ...[
          Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.mediumGray),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Center(
                  child: Image.network(
                    url,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    onPressed: () => onChanged(null),
                    icon: const Icon(Icons.close, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: () async {
              // TODO: تنفيذ رفع الصورة
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم تنفيذ رفع الصور قريباً')),
              );
            },
            icon: const Icon(Icons.upload),
            label: Text('رفع $label'),
          ),
        ],
      ],
    );
  }

  Widget _buildVariablesHelp() {
    return Card(
      color: AppTheme.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: AppTheme.blue),
                const SizedBox(width: 8),
                const Text(
                  'المتغيرات المتاحة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'يمكنك استخدام المتغيرات التالية في النصوص:',
              style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
            ),
            const SizedBox(height: 8),
            _buildVariableItem('{{student_name}}', 'اسم الطالب'),
            _buildVariableItem('{{course_name}}', 'اسم الدورة'),
            _buildVariableItem('{{completion_date}}', 'تاريخ الإكمال'),
            _buildVariableItem('{{provider_name}}', 'اسم الجهة'),
            _buildVariableItem('{{certificate_number}}', 'رقم الشهادة'),
          ],
        ),
      ),
    );
  }

  Widget _buildVariableItem(String variable, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.darkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              variable,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: AppTheme.darkGray),
          ),
        ],
      ),
    );
  }
}
