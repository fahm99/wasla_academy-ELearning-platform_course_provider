import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../data/models/certificate/certificate.dart';
import '../../../blocs/certificate/certificate_exports.dart';

class CertificateSettingsDialog extends StatefulWidget {
  final String courseId;
  final CertificateSettings? initialSettings;

  const CertificateSettingsDialog({
    super.key,
    required this.courseId,
    this.initialSettings,
  });

  @override
  State<CertificateSettingsDialog> createState() =>
      _CertificateSettingsDialogState();
}

class _CertificateSettingsDialogState extends State<CertificateSettingsDialog> {
  late bool _autoIssue;
  late String _customColor;
  String? _logoUrl;
  String? _signatureUrl;

  @override
  void initState() {
    super.initState();
    _autoIssue = widget.initialSettings?.autoIssue ?? false;
    _customColor = widget.initialSettings?.customColor ?? '#1E3A8A';
    _logoUrl = widget.initialSettings?.logoUrl;
    _signatureUrl = widget.initialSettings?.signatureUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildContent(),
              ),
            ),
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
          const Icon(
            AppIcons.settings,
            color: AppTheme.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'إعدادات الشهادة',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAutoIssueSection(),
        const SizedBox(height: 24),
        _buildColorSection(),
        const SizedBox(height: 24),
        _buildLogoSection(),
        const SizedBox(height: 24),
        _buildSignatureSection(),
      ],
    );
  }

  Widget _buildAutoIssueSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                AppIcons.active,
                color: AppTheme.darkBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'الإصدار التلقائي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ),
              Switch(
                value: _autoIssue,
                onChanged: (value) {
                  setState(() {
                    _autoIssue = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'عند التفعيل، سيتم إصدار الشهادات تلقائياً للطلاب الذين أكملوا الكورس ونجحوا في الامتحان',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.palette,
              color: AppTheme.darkBlue,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'اللون المخصص',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _showColorPicker,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightGray),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hexToColor(_customColor),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.lightGray),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'اللون الحالي',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      Text(
                        _customColor,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.edit,
                  color: AppTheme.blue,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.image,
              color: AppTheme.darkBlue,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'شعار مقدم الخدمة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.lightGray),
          ),
          child: Column(
            children: [
              if (_logoUrl != null)
                Container(
                  height: 80,
                  width: 80,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(_logoUrl!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _uploadLogo,
                      icon: const Icon(AppIcons.upload, size: 16),
                      label:
                          Text(_logoUrl == null ? 'رفع شعار' : 'تغيير الشعار'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.blue,
                        foregroundColor: AppTheme.white,
                      ),
                    ),
                  ),
                  if (_logoUrl != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _logoUrl = null;
                        });
                      },
                      icon: const Icon(Icons.delete, color: AppTheme.red),
                      tooltip: 'حذف الشعار',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.draw,
              color: AppTheme.darkBlue,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'توقيع مقدم الخدمة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.lightGray),
          ),
          child: Column(
            children: [
              if (_signatureUrl != null)
                Container(
                  height: 60,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(_signatureUrl!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _uploadSignature,
                      icon: const Icon(AppIcons.upload, size: 16),
                      label: Text(_signatureUrl == null
                          ? 'رفع توقيع'
                          : 'تغيير التوقيع'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.blue,
                        foregroundColor: AppTheme.white,
                      ),
                    ),
                  ),
                  if (_signatureUrl != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _signatureUrl = null;
                        });
                      },
                      icon: const Icon(Icons.delete, color: AppTheme.red),
                      tooltip: 'حذف التوقيع',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return BlocConsumer<CertificateBloc, CertificateState>(
      listener: (context, state) {
        if (state is CertificateSettingsSaved) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.green,
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
        final isSaving = state is CertificateLoading;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.lightGray.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
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
                  onPressed: isSaving ? null : _saveSettings,
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppTheme.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ الإعدادات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkBlue,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorPicker() {
    Color currentColor = _hexToColor(_customColor);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر اللون'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              currentColor = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _customColor = _colorToHex(currentColor);
              });
              Navigator.pop(context);
            },
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  void _uploadLogo() {
    // TODO: تنفيذ رفع الشعار
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('رفع الشعار - قيد التطوير'),
        backgroundColor: AppTheme.blue,
      ),
    );
  }

  void _uploadSignature() {
    // TODO: تنفيذ رفع التوقيع
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('رفع التوقيع - قيد التطوير'),
        backgroundColor: AppTheme.blue,
      ),
    );
  }

  void _saveSettings() {
    final settings = CertificateSettings(
      courseId: widget.courseId,
      autoIssue: _autoIssue,
      logoUrl: _logoUrl,
      signatureUrl: _signatureUrl,
      customColor: _customColor,
    );

    context.read<CertificateBloc>().add(
          SaveCertificateSettings(
            courseId: widget.courseId,
            settings: settings,
          ),
        );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
