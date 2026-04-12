import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_icons.dart';
import '../../data/models/certificate/certificate.dart';
import '../widgets/certificate_template.dart';

class CertificatePreviewScreen extends StatelessWidget {
  final Certificate certificate;

  const CertificatePreviewScreen({
    super.key,
    required this.certificate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkGray.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: AppTheme.darkBlue,
        foregroundColor: AppTheme.white,
        title: const Text('معاينة الشهادة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'العودة',
        ),
        actions: [
          IconButton(
            onPressed: () => _downloadCertificate(context),
            icon: const Icon(AppIcons.download),
            tooltip: 'تحميل الشهادة',
          ),
          IconButton(
            onPressed: () => _shareCertificate(context),
            icon: const Icon(AppIcons.send),
            tooltip: 'مشاركة الشهادة',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // معلومات الشهادة
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'شهادة: ${certificate.studentName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'رقم الشهادة: ${certificate.certificateNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // قالب الشهادة
              CertificateTemplate(
                certificate: certificate,
                showBorder: true,
              ),

              // أزرار الإجراءات
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _downloadCertificate(context),
                    icon: const Icon(AppIcons.download),
                    label: const Text('تحميل كـ PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _downloadAsImage(context),
                    icon: const Icon(Icons.image),
                    label: const Text('تحميل كصورة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blue,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _shareCertificate(context),
                    icon: const Icon(AppIcons.send),
                    label: const Text('مشاركة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkBlue,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _printCertificate(context),
                    icon: const Icon(Icons.print),
                    label: const Text('طباعة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.white,
                      side: const BorderSide(color: AppTheme.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),

              // معلومات التحقق
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.white.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: AppTheme.green,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'شهادة موثقة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'يمكن التحقق من صحة هذه الشهادة باستخدام رقم الشهادة',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadCertificate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تحميل الشهادة كـ PDF...'),
        backgroundColor: AppTheme.green,
      ),
    );
    // TODO: تنفيذ التحميل كـ PDF
  }

  void _downloadAsImage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تحميل الشهادة كصورة...'),
        backgroundColor: AppTheme.blue,
      ),
    );
    // TODO: تنفيذ التحميل كصورة
  }

  void _shareCertificate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري مشاركة الشهادة...'),
        backgroundColor: AppTheme.darkBlue,
      ),
    );
    // TODO: تنفيذ المشاركة
  }

  void _printCertificate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تجهيز الشهادة للطباعة...'),
        backgroundColor: AppTheme.darkGray,
      ),
    );
    // TODO: تنفيذ الطباعة
  }
}
