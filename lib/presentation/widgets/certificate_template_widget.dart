import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';

class CertificateTemplateWidget extends StatefulWidget {
  final String studentName;
  final String specialization;
  final String certificateId;
  final String issueDate;
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

  const CertificateTemplateWidget({
    super.key,
    required this.studentName,
    required this.specialization,
    required this.certificateId,
    required this.issueDate,
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
  });

  @override
  CertificateTemplateWidgetState createState() =>
      CertificateTemplateWidgetState();
}

class SignatureData {
  final String name;
  final String title;

  const SignatureData({
    required this.name,
    required this.title,
  });
}

class CertificateTemplateWidgetState extends State<CertificateTemplateWidget> {
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Screenshot(
        controller: screenshotController,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: widget.primaryColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // العلامة المائية
              if (widget.showWatermark)
                Center(
                  child: Transform.rotate(
                    angle: -0.785398, // -45 degrees in radians
                    child: Text(
                      widget.partnerName,
                      style: TextStyle(
                        fontSize: 80,
                        color: widget.primaryColor.withOpacity(0.05),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // زوايا الحدود
              Positioned(
                top: -3,
                left: -3,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: widget.accentColor, width: 3),
                      left: BorderSide(color: widget.accentColor, width: 3),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -3,
                right: -3,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: widget.accentColor, width: 3),
                      right: BorderSide(color: widget.accentColor, width: 3),
                    ),
                  ),
                ),
              ),

              // محتوى الشهادة
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    // الهيدر
                    _buildHeader(),
                    const SizedBox(height: 30),

                    // العنوان الرئيسي
                    Text(
                      widget.certificateTitle,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // العنوان الفرعي
                    Text(
                      widget.certificateSubtitle,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // نص الشهادة
                    Text(
                      widget.certificateText,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF333333),
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // اسم الطالب
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: widget.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        widget.studentName,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: widget.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // معلومات الطالب
                    Text(
                      'تخصص: ${widget.specialization}',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // تاريخ الشهادة
                    Text(
                      'صدرت في: ${widget.issueDate}\nرقم الشهادة: ${widget.certificateId}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF555555),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),

                    // التوقيعات
                    _buildSignatures(),
                  ],
                ),
              ),

              // الختم
              Positioned(
                bottom: 40,
                right: 40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: widget.accentColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: Transform.rotate(
                    angle: -0.261799, // -15 degrees in radians
                    child: Center(
                      child: Text(
                        widget.sealText,
                        style: TextStyle(
                          color: widget.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // معرف الشهادة
              Positioned(
                bottom: 20,
                left: 20,
                child: Text(
                  'معرف الشهادة: ${widget.certificateId}-WASLA-PROG',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // الشعار الأيسر
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: widget.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.account_balance,
            color: Colors.white,
            size: 40,
          ),
        ),
        // الشعار الأوسط
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: widget.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school,
            color: Colors.white,
            size: 40,
          ),
        ),
        // الشعار الأيمن
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: widget.accentColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.card_membership,
            color: widget.primaryColor,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildSignatures() {
    final defaultSignatures = [
      const SignatureData(name: 'يحيى الصبري', title: 'رئيس قسم الهندسة'),
      const SignatureData(name: 'عبدالملك المقطري', title: 'عميد كلية الهندسة'),
      const SignatureData(name: 'المهندس فهمي العامري', title: 'مؤسس المنصة'),
      const SignatureData(name: 'المهندس هيكل المخلافي', title: 'المدرب'),
    ];

    final signatures =
        widget.signatures.isNotEmpty ? widget.signatures : defaultSignatures;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: signatures.map((signature) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              children: [
                Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF333333),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  signature.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  signature.title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> downloadCertificate() async {
    try {
      // التقاط الشهادة كصورة
      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/certificate_${widget.certificateId}.png';

      await screenshotController.captureAndSave(
        directory.path,
        fileName: 'certificate_${widget.certificateId}.png',
      );

      // مشاركة الصورة
      await Share.shareXFiles([XFile(imagePath)], text: 'شهادة تخرج');
    } catch (e) {
      throw Exception('حدث خطأ أثناء تحميل الشهادة: $e');
    }
  }
}
