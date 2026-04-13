import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/certificate/certificate.dart';

class CertificateTemplate extends StatelessWidget {
  final Certificate certificate;
  final bool showBorder;

  const CertificateTemplate({
    super.key,
    required this.certificate,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final customColor = _hexToColor(certificate.customColor);

    return Container(
      width: 800,
      height: 600,
      decoration: BoxDecoration(
        color: AppTheme.white,
        border:
            showBorder ? Border.all(color: AppTheme.lightGray, width: 2) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // خلفية زخرفية
          _buildBackground(customColor),

          // المحتوى
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                _buildHeader(customColor),
                const Spacer(),
                _buildContent(),
                const Spacer(),
                _buildFooter(customColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(Color customColor) {
    return Positioned.fill(
      child: CustomPaint(
        painter: CertificateBackgroundPainter(customColor),
      ),
    );
  }

  Widget _buildHeader(Color customColor) {
    return Column(
      children: [
        // شعار المنصة أو مقدم الخدمة
        if (certificate.providerLogoUrl != null)
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.white,
              border: Border.all(color: customColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: customColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                certificate.providerLogoUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.school, size: 40, color: customColor);
                },
              ),
            ),
          )
        else
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: customColor.withOpacity(0.1),
              border: Border.all(color: customColor, width: 3),
            ),
            child: Icon(Icons.school, size: 40, color: customColor),
          ),
        const SizedBox(height: 20),

        // عنوان الشهادة
        Text(
          'شهادة إتمام',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: customColor,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                customColor.withOpacity(0.3),
                customColor,
                customColor.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        const Text(
          'هذه الشهادة تُمنح لـ',
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 16),

        // اسم الطالب
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.darkBlue.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          child: Text(
            certificate.studentName,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkBlue,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),

        // وصف الإنجاز
        const Text(
          'لإتمامه بنجاح كورس',
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          certificate.courseName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkBlue,
          ),
          textAlign: TextAlign.center,
        ),

        // الدرجة إذا كانت موجودة
        if (certificate.grade != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.green, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: AppTheme.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'التقدير: ${certificate.grade}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(Color customColor) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // التاريخ
            _buildInfoColumn(
              'تاريخ الإصدار',
              dateFormat.format(certificate.issueDate),
              Icons.calendar_today,
              customColor,
            ),

            // رقم الشهادة
            _buildInfoColumn(
              'رقم الشهادة',
              certificate.certificateNumber,
              Icons.tag,
              customColor,
            ),

            // مقدم الخدمة
            _buildInfoColumn(
              'مقدم الخدمة',
              certificate.providerName,
              Icons.business,
              customColor,
            ),
          ],
        ),

        // التوقيع
        if (certificate.providerSignatureUrl != null) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    height: 60,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.darkGray.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Image.network(
                      certificate.providerSignatureUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox();
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'توقيع مقدم الخدمة',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class CertificateBackgroundPainter extends CustomPainter {
  final Color color;

  CertificateBackgroundPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // رسم دوائر زخرفية في الخلفية
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.1),
      80,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1),
      80,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.9),
      80,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.9),
      80,
      paint,
    );

    // رسم خطوط زخرفية
    final linePaint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.35,
      size.width,
      size.height * 0.3,
    );
    canvas.drawPath(path, linePaint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.7,
    );
    path2.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.65,
      size.width,
      size.height * 0.7,
    );
    canvas.drawPath(path2, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
