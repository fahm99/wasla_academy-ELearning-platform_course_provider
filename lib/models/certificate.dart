import 'package:equatable/equatable.dart';

class Certificate extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String courseId;
  final String courseName;
  final String providerId;
  final String providerName;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final CertificateStatus status;
  final String? certificateUrl;

  const Certificate({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseName,
    required this.providerId,
    required this.providerName,
    required this.issuedAt,
    this.expiresAt,
    this.status = CertificateStatus.active,
    this.certificateUrl,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        studentName,
        courseId,
        courseName,
        providerId,
        providerName,
        issuedAt,
        expiresAt,
        status,
        certificateUrl
      ];

  Certificate copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? courseId,
    String? courseName,
    String? providerId,
    String? providerName,
    DateTime? issuedAt,
    DateTime? expiresAt,
    CertificateStatus? status,
    String? certificateUrl,
  }) {
    return Certificate(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      certificateUrl: certificateUrl ?? this.certificateUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'courseId': courseId,
      'courseName': courseName,
      'providerId': providerId,
      'providerName': providerName,
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status.name,
      'certificateUrl': certificateUrl,
    };
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      courseId: json['courseId'],
      courseName: json['courseName'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      issuedAt: DateTime.parse(json['issuedAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      status:
          CertificateStatus.values.firstWhere((e) => e.name == json['status']),
      certificateUrl: json['certificateUrl'],
    );
  }
}

enum CertificateStatus { active, revoked, expired }
