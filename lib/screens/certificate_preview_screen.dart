import 'package:flutter/material.dart';
import '../widgets/certificate_template_widget.dart';
import '../theme/Theme.dart';

class CertificatePreviewScreen extends StatelessWidget {
  const CertificatePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // إنشاء GlobalKey للوصول إلى state الخاص بالشهادة
    final GlobalKey<CertificateTemplateWidgetState> certificateKey =
        GlobalKey<CertificateTemplateWidgetState>();
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.preview,
                size: 20,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'معاينة الشهادة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBlue,
                AppTheme.blue,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkBlue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.share,
                  size: 20,
                  color: AppTheme.white,
                ),
              ),
              onPressed: () {
                // مشاركة الشهادة
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('مشاركة الشهادة...')),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppTheme.white,
                ),
              ),
              onPressed: () {
                _showMoreOptions(context);
              },
            ),
          ),
        ],
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: AppTheme.white,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // الشهادة
              CertificateTemplateWidget(
                key: certificateKey,
                studentName: 'أحمد محمد علي السالمي',
                specialization: 'هندسة البرمجيات',
                certificateId: 'CERT-2024-001',
                issueDate: '2024/12/07',
                institutionName: 'الجامعة الوطنية',
                partnerName: 'منصة وصلة',
                programName: 'هندسة البرمجيات',
                signatures: const [
                  SignatureData(
                      name: 'يحيى الصبري', title: 'رئيس قسم الهندسة'),
                  SignatureData(
                      name: 'عبدالملك المقطري', title: 'عميد كلية الهندسة'),
                  SignatureData(
                      name: 'المهندس فهمي العامري', title: 'مؤسس المنصة'),
                  SignatureData(
                      name: 'المهندس هيكل المخلافي', title: 'المدرب'),
                ],
              ),

              const SizedBox(height: 30),

              // أزرار الإجراءات
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جاري تجهيز الطباعة...')),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('طباعة الشهادة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0c1445),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        // استخدام GlobalKey للوصول إلى دالة التحميل
                        await certificateKey.currentState
                            ?.downloadCertificate();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تم تحميل الشهادة بنجاح')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('حدث خطأ أثناء تحميل الشهادة: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('تحميل الشهادة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9D71C),
                      foregroundColor: const Color(0xFF0c1445),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.blue),
              title: const Text('تحرير الشهادة'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فتح محرر الشهادة...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: AppTheme.green),
              title: const Text('نسخ رابط الشهادة'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ الرابط')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.yellow),
              title: const Text('إرسال بالبريد الإلكتروني'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فتح البريد الإلكتروني...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: AppTheme.darkBlue),
              title: const Text('إنشاء رمز QR'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('إنشاء رمز QR...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
