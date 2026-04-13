import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/core/utils/app_icons.dart';
import 'package:course_provider/data/models/certificate/certificate_template.dart';
import 'package:course_provider/data/models/certificate/signature_data.dart';
import 'package:course_provider/presentation/widgets/certificate_template_widget.dart';
import 'signature_dialog.dart';

class EditTemplateDialog extends StatefulWidget {
  final CertificateTemplate template;
  final Function(CertificateTemplate) onSave;

  const EditTemplateDialog({
    super.key,
    required this.template,
    required this.onSave,
  });

  @override
  State<EditTemplateDialog> createState() => _EditTemplateDialogState();
}

class _EditTemplateDialogState extends State<EditTemplateDialog> {
  late TextEditingController _templateNameController;
  late TextEditingController _institutionNameController;
  late TextEditingController _partnerNameController;
  late TextEditingController _programNameController;
  late TextEditingController _certificateTitleController;
  late TextEditingController _certificateSubtitleController;
  late TextEditingController _certificateTextController;
  late TextEditingController _sealTextController;

  bool _showWatermark = true;
  Color _primaryColor = const Color(0xFF0c1445);
  Color _accentColor = const Color(0xFFF9D71C);
  List<SignatureData> _signatures = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSettings();
  }

  void _initializeControllers() {
    _templateNameController = TextEditingController(text: widget.template.name);
    _institutionNameController = TextEditingController(
        text: widget.template.templateData.customFields?['institutionName'] ??
            '');
    _partnerNameController = TextEditingController(
        text: widget.template.templateData.customFields?['partnerName'] ?? '');
    _programNameController = TextEditingController(
        text: widget.template.templateData.customFields?['programName'] ?? '');
    _certificateTitleController =
        TextEditingController(text: widget.template.templateData.headerText);
    _certificateSubtitleController = TextEditingController(
        text:
            widget.template.templateData.customFields?['certificateSubtitle'] ??
                '');
    _certificateTextController =
        TextEditingController(text: widget.template.templateData.bodyText);
    _sealTextController =
        TextEditingController(text: widget.template.templateData.footerText);
  }

  void _loadSettings() {
    _showWatermark =
        widget.template.templateData.customFields?['showWatermark'] ?? true;
    _primaryColor = _parseColor(widget.template.templateData.primaryColor);
    _accentColor = _parseColor(widget.template.templateData.secondaryColor);
    _signatures =
        (widget.template.templateData.customFields?['signatures'] as List?)
                ?.map((s) => SignatureData.fromJson(s))
                .toList() ??
            [];
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
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
              _buildBasicInfoFields(),
              const SizedBox(height: AppTheme.paddingMedium),
              _buildCertificateTextFields(),
              const SizedBox(height: AppTheme.paddingMedium),
              _buildWatermarkSwitch(),
              const SizedBox(height: AppTheme.paddingMedium),
              _buildColorPickers(),
              const SizedBox(height: AppTheme.paddingMedium),
              _buildSignaturesSection(),
              const SizedBox(height: AppTheme.paddingMedium),
              _buildFileUploadButtons(),
              const SizedBox(height: AppTheme.paddingMedium),
              _buildPreviewButton(),
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
          onPressed: _saveTemplate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkBlue,
            foregroundColor: AppTheme.white,
          ),
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  Widget _buildBasicInfoFields() {
    return Column(
      children: [
        TextField(
          controller: _templateNameController,
          decoration: const InputDecoration(
            labelText: 'اسم القالب',
            hintText: 'مثال: شهادة دورة Flutter',
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        TextField(
          controller: _institutionNameController,
          decoration: const InputDecoration(
            labelText: 'اسم المؤسسة',
            hintText: 'مثال: الجامعة الوطنية',
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        TextField(
          controller: _partnerNameController,
          decoration: const InputDecoration(
            labelText: 'اسم الشريك',
            hintText: 'مثال: منصة وصل',
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        TextField(
          controller: _programNameController,
          decoration: const InputDecoration(
            labelText: 'اسم البرنامج',
            hintText: 'مثال: هندسة البرمجيات',
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateTextFields() {
    return Column(
      children: [
        TextField(
          controller: _certificateTitleController,
          decoration: const InputDecoration(
            labelText: 'عنوان الشهادة',
            hintText: 'مثال: شهادة تخرج',
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        TextField(
          controller: _certificateSubtitleController,
          decoration: const InputDecoration(
            labelText: 'العنوان الفرعي',
            hintText: 'مثال: الجامعة الوطنية بالشراكة مع منصة وصل',
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        TextField(
          controller: _certificateTextController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'نص الشهادة',
            hintText: 'النص الذي يظهر في الشهادة...',
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        TextField(
          controller: _sealTextController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'نص الختم',
            hintText: 'مثال: ختم معتمد\\nالجامعة الوطنية',
          ),
        ),
      ],
    );
  }

  Widget _buildWatermarkSwitch() {
    return SwitchListTile(
      title: const Text('إظهار العلامة المائية'),
      value: _showWatermark,
      onChanged: (value) {
        setState(() {
          _showWatermark = value;
        });
      },
    );
  }

  Widget _buildColorPickers() {
    return Row(
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
    );
  }

  Widget _buildSignaturesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'التوقيعات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addSignature,
              icon: const Icon(Icons.add, color: AppTheme.yellow),
              label: const Text('إضافة توقيع'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBlue,
                foregroundColor: AppTheme.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
      ],
    );
  }

  Widget _buildFileUploadButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('رفع الشعار')),
              );
            },
            icon: const Icon(AppIcons.image, color: AppTheme.yellow),
            label: const Text('رفع الشعار'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkBlue,
              foregroundColor: AppTheme.white,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.paddingSmall),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('رفع التوقيع')),
              );
            },
            icon: const Icon(AppIcons.edit, color: AppTheme.yellow),
            label: const Text('رفع التوقيع'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkBlue,
              foregroundColor: AppTheme.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showTemplatePreview,
        icon: const Icon(AppIcons.eye, color: AppTheme.darkBlue),
        label: const Text('معاينة القالب'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.darkBlue,
          side: const BorderSide(color: AppTheme.darkBlue),
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
      builder: (context) => SignatureDialog(
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
      builder: (context) => SignatureDialog(
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

  void _showTemplatePreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Transform.scale(
                    scale: 0.7,
                    child: CertificateTemplateWidget(
                      studentName: 'اسم الطالب التجريبي',
                      specialization: _programNameController.text.isNotEmpty
                          ? _programNameController.text
                          : widget.template.templateData
                                  .customFields?['programName'] ??
                              '',
                      certificateId: 'CERT-2024-001',
                      issueDate: '2024/12/07',
                      institutionName:
                          _institutionNameController.text.isNotEmpty
                              ? _institutionNameController.text
                              : widget.template.templateData
                                      .customFields?['institutionName'] ??
                                  '',
                      partnerName: _partnerNameController.text.isNotEmpty
                          ? _partnerNameController.text
                          : widget.template.templateData
                                  .customFields?['partnerName'] ??
                              '',
                      programName: _programNameController.text.isNotEmpty
                          ? _programNameController.text
                          : widget.template.templateData
                                  .customFields?['programName'] ??
                              '',
                      certificateTitle:
                          _certificateTitleController.text.isNotEmpty
                              ? _certificateTitleController.text
                              : widget.template.templateData.headerText,
                      certificateSubtitle:
                          _certificateSubtitleController.text.isNotEmpty
                              ? _certificateSubtitleController.text
                              : widget.template.templateData
                                      .customFields?['certificateSubtitle'] ??
                                  '',
                      certificateText:
                          _certificateTextController.text.isNotEmpty
                              ? _certificateTextController.text
                              : widget.template.templateData.bodyText,
                      signatures: _signatures.isNotEmpty
                          ? _signatures
                          : (widget.template.templateData
                                      .customFields?['signatures'] as List?)
                                  ?.map((s) => SignatureData.fromJson(s))
                                  .toList() ??
                              [],
                      sealText: _sealTextController.text.isNotEmpty
                          ? _sealTextController.text
                          : widget.template.templateData.footerText,
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

  void _saveTemplate() {
    final customFields = {
      'institutionName': _institutionNameController.text,
      'partnerName': _partnerNameController.text,
      'programName': _programNameController.text,
      'certificateSubtitle': _certificateSubtitleController.text,
      'showWatermark': _showWatermark,
      'signatures': _signatures.map((s) => s.toJson()).toList(),
    };

    final updatedTemplateData = widget.template.templateData.copyWith(
      primaryColor: _colorToHex(_primaryColor),
      secondaryColor: _colorToHex(_accentColor),
      headerText: _certificateTitleController.text,
      bodyText: _certificateTextController.text,
      footerText: _sealTextController.text,
      customFields: customFields,
    );

    final updatedTemplate = widget.template.copyWith(
      name: _templateNameController.text,
      templateData: updatedTemplateData,
      updatedAt: DateTime.now(),
    );

    widget.onSave(updatedTemplate);
    Navigator.pop(context);
  }
}
