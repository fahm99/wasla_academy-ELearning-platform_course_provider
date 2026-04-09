import 'package:flutter/material.dart';
import 'signature_data.dart';

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
