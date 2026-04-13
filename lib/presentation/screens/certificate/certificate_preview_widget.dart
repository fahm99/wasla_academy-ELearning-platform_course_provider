import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/certificate/certificate_template.dart';

class CertificatePreviewWidget extends StatelessWidget {
  final TemplateData templateData;
  final String studentName;
  final String courseName;
  final DateTime completionDate;
  final String providerName;
  final String certificateNumber;

  const CertificatePreviewWidget({
    super.key,
    required this.templateData,
    required this.studentName,
    required this.courseName,
    required this.completionDate,
    required this.providerName,
    required this.certificateNumber,
  });

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  String _replaceVariables(String text) {
    final variables = {
      'student_name': studentName,
      'course_name': courseName,
      'completion_date': DateFormat('yyyy-MM-dd').format(completionDate),
      'provider_name': providerName,
      'certificate_number': certificateNumber,
    };
    return templateData.replaceVariables(text, variables);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _parseColor(templateData.primaryColor);
    final secondaryColor = _parseColor(templateData.secondaryColor);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1.414, // A4 ratio
        child: Stack(
          children: [
            // خلفية زخرفية
            Positioned.fill(
              child: CustomPaint(
                painter: CertificateBackgroundPainter(
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                ),
              ),
            ),
            // المحتوى
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // الرأس
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // الشعار
                      if (templateData.logoUrl != null)
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: secondaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.network(
                            templateData.logoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image, color: primaryColor);
                            },
                          ),
                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: secondaryColor.withOpacity(0.2),
                            border: Border.all(color: secondaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              Icon(Icons.school, color: primaryColor, size: 30),
                        ),
                      // معلومات الجهة
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            providerName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            certificateNumber,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // العنوان
                  Text(
                    _replaceVariables(templateData.headerText),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 4,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // اسم الطالب
                  Text(
                    studentName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // نص المحتوى
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _replaceVariables(templateData.bodyText),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // اسم الدورة
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      courseName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  // التوقيع والتاريخ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // QR Code placeholder
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.qr_code,
                            color: Colors.grey.shade400, size: 40),
                      ),
                      // التوقيع
                      Column(
                        children: [
                          if (templateData.signatureUrl != null)
                            Image.network(
                              templateData.signatureUrl!,
                              width: 120,
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 120,
                                  height: 60,
                                  color: Colors.grey.shade200,
                                );
                              },
                            )
                          else
                            Container(
                              width: 120,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  'التوقيع',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Container(
                            width: 120,
                            height: 2,
                            color: primaryColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            providerName,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      // التاريخ
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'تاريخ الإصدار',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd').format(completionDate),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CertificateBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  CertificateBackgroundPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // إطار خارجي
    paint.color = primaryColor;
    canvas.drawRect(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      paint,
    );

    // إطار داخلي
    paint.color = secondaryColor;
    canvas.drawRect(
      Rect.fromLTWH(15, 15, size.width - 30, size.height - 30),
      paint,
    );

    // زخارف الزوايا
    paint.style = PaintingStyle.fill;
    paint.color = secondaryColor.withOpacity(0.3);

    // زاوية علوية يسرى
    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(80, 0)
      ..lineTo(0, 80)
      ..close();
    canvas.drawPath(path1, paint);

    // زاوية علوية يمنى
    final path2 = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width - 80, 0)
      ..lineTo(size.width, 80)
      ..close();
    canvas.drawPath(path2, paint);

    // زاوية سفلية يسرى
    final path3 = Path()
      ..moveTo(0, size.height)
      ..lineTo(80, size.height)
      ..lineTo(0, size.height - 80)
      ..close();
    canvas.drawPath(path3, paint);

    // زاوية سفلية يمنى
    final path4 = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width - 80, size.height)
      ..lineTo(size.width, size.height - 80)
      ..close();
    canvas.drawPath(path4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
