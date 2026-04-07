import 'package:equatable/equatable.dart';

class Certificate extends Equatable {
  final String id;
  final String courseId;
  final String studentId;
  final String providerId;
  final String certificateNumber;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final Map<String, dynamic>? templateDesign;
  final String? certificateUrl;
  final CertificateStatus status;
  final DateTime createdAt;

  const Certificate({
    required this.id,
    required this.courseId,
    required this.studentId,
    required this.providerId,
    required this.certificateNumber,
    required this.issueDate,
    this.expiryDate,
    this.templateDesign,
    this.certificateUrl,
    this.status = CertificateStatus.issued,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        studentId,
        providerId,
        certificateNumber,
        issueDate,
        expiryDate,
        templateDesign,
        certificateUrl,
        status,
        createdAt,
      ];

  Certificate copyWith({
    String? id,
    String? courseId,
    String? studentId,
    String? providerId,
    String? certificateNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    Map<String, dynamic>? templateDesign,
    String? certificateUrl,
    CertificateStatus? status,
    DateTime? createdAt,
  }) {
    return Certificate(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      studentId: studentId ?? this.studentId,
      providerId: providerId ?? this.providerId,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      templateDesign: templateDesign ?? this.templateDesign,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'student_id': studentId,
      'provider_id': providerId,
      'certificate_number': certificateNumber,
      'issue_date': issueDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'template_design': templateDesign,
      'certificate_url': certificateUrl,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      studentId: json['student_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      certificateNumber: json['certificate_number'] ?? '',
      issueDate: DateTime.parse(
          json['issue_date'] ?? DateTime.now().toIso8601String()),
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      templateDesign: json['template_design'],
      certificateUrl: json['certificate_url'],
      status: CertificateStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'issued'),
        orElse: () => CertificateStatus.issued,
      ),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum CertificateStatus { issued, revoked }
