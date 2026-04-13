import 'package:equatable/equatable.dart';

class Certificate extends Equatable {
  final String id;
  final String courseId;
  final String courseName;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String providerId;
  final String providerName;
  final String certificateNumber;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final DateTime? completionDate;
  final String? providerLogoUrl;
  final String? providerSignatureUrl;
  final String customColor;
  final bool autoIssue;
  final String? grade;
  final CertificateStatus status;
  final String? certificateUrl;

  const Certificate({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.providerId,
    required this.providerName,
    required this.certificateNumber,
    required this.issueDate,
    this.expiryDate,
    this.completionDate,
    this.providerLogoUrl,
    this.providerSignatureUrl,
    this.customColor = '#1E3A8A',
    this.autoIssue = false,
    this.grade,
    this.status = CertificateStatus.issued,
    this.certificateUrl,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseName,
        studentId,
        studentName,
        studentEmail,
        providerId,
        providerName,
        certificateNumber,
        issueDate,
        expiryDate,
        completionDate,
        providerLogoUrl,
        providerSignatureUrl,
        customColor,
        autoIssue,
        grade,
        status,
        certificateUrl,
      ];

  Certificate copyWith({
    String? id,
    String? courseId,
    String? courseName,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? providerId,
    String? providerName,
    String? certificateNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    DateTime? completionDate,
    String? providerLogoUrl,
    String? providerSignatureUrl,
    String? customColor,
    bool? autoIssue,
    String? grade,
    CertificateStatus? status,
    String? certificateUrl,
  }) {
    return Certificate(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      completionDate: completionDate ?? this.completionDate,
      providerLogoUrl: providerLogoUrl ?? this.providerLogoUrl,
      providerSignatureUrl: providerSignatureUrl ?? this.providerSignatureUrl,
      customColor: customColor ?? this.customColor,
      autoIssue: autoIssue ?? this.autoIssue,
      grade: grade ?? this.grade,
      status: status ?? this.status,
      certificateUrl: certificateUrl ?? this.certificateUrl,
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
      'completion_date': completionDate?.toIso8601String(),
      'provider_logo_url': providerLogoUrl,
      'provider_signature_url': providerSignatureUrl,
      'custom_color': customColor,
      'auto_issue': autoIssue,
      'grade': grade,
      'status': status.name,
      'certificate_url': certificateUrl,
    };
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      courseName: _extractCourseName(json),
      studentId: json['student_id'] ?? '',
      studentName: _extractStudentName(json),
      studentEmail: _extractStudentEmail(json),
      providerId: json['provider_id'] ?? '',
      providerName: _extractProviderName(json),
      certificateNumber: json['certificate_number'] ?? '',
      issueDate: DateTime.parse(
        json['issue_date'] ?? DateTime.now().toIso8601String(),
      ),
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
      providerLogoUrl: json['provider_logo_url'],
      providerSignatureUrl: json['provider_signature_url'],
      customColor: json['custom_color'] ?? '#1E3A8A',
      autoIssue: json['auto_issue'] ?? false,
      grade: json['grade'],
      status: CertificateStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'issued'),
        orElse: () => CertificateStatus.issued,
      ),
      certificateUrl: json['certificate_url'],
    );
  }

  static String _extractCourseName(Map<String, dynamic> json) {
    if (json['courses'] != null) {
      if (json['courses'] is Map) {
        return json['courses']['title'] ?? '';
      }
    }
    return json['course_name'] ?? '';
  }

  static String _extractStudentName(Map<String, dynamic> json) {
    if (json['users'] != null) {
      if (json['users'] is Map) {
        return json['users']['name'] ?? '';
      } else if (json['users'] is List && (json['users'] as List).isNotEmpty) {
        return json['users'][0]['name'] ?? '';
      }
    }
    return json['student_name'] ?? '';
  }

  static String _extractStudentEmail(Map<String, dynamic> json) {
    if (json['users'] != null) {
      if (json['users'] is Map) {
        return json['users']['email'] ?? '';
      } else if (json['users'] is List && (json['users'] as List).isNotEmpty) {
        return json['users'][0]['email'] ?? '';
      }
    }
    return json['student_email'] ?? '';
  }

  static String _extractProviderName(Map<String, dynamic> json) {
    if (json['provider'] != null && json['provider'] is Map) {
      return json['provider']['name'] ?? '';
    }
    return json['provider_name'] ?? '';
  }
}

enum CertificateStatus { issued, revoked }

/// نموذج إعدادات الشهادة للكورس
class CertificateSettings extends Equatable {
  final String courseId;
  final bool autoIssue;
  final String? logoUrl;
  final String? signatureUrl;
  final String customColor;

  const CertificateSettings({
    required this.courseId,
    this.autoIssue = false,
    this.logoUrl,
    this.signatureUrl,
    this.customColor = '#1E3A8A',
  });

  @override
  List<Object?> get props => [
        courseId,
        autoIssue,
        logoUrl,
        signatureUrl,
        customColor,
      ];

  CertificateSettings copyWith({
    String? courseId,
    bool? autoIssue,
    String? logoUrl,
    String? signatureUrl,
    String? customColor,
  }) {
    return CertificateSettings(
      courseId: courseId ?? this.courseId,
      autoIssue: autoIssue ?? this.autoIssue,
      logoUrl: logoUrl ?? this.logoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      customColor: customColor ?? this.customColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificate_auto_issue': autoIssue,
      'certificate_logo_url': logoUrl,
      'certificate_signature_url': signatureUrl,
      'certificate_custom_color': customColor,
    };
  }

  factory CertificateSettings.fromJson(Map<String, dynamic> json) {
    return CertificateSettings(
      courseId: json['id'] ?? json['course_id'] ?? '',
      autoIssue: json['certificate_auto_issue'] ?? false,
      logoUrl: json['certificate_logo_url'],
      signatureUrl: json['certificate_signature_url'],
      customColor: json['certificate_custom_color'] ?? '#1E3A8A',
    );
  }
}

/// نموذج الطالب المؤهل للحصول على الشهادة
class EligibleStudent extends Equatable {
  final String studentId;
  final String studentName;
  final String studentEmail;
  final int progress;
  final int? examScore;
  final DateTime? completionDate;

  const EligibleStudent({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.progress,
    this.examScore,
    this.completionDate,
  });

  @override
  List<Object?> get props => [
        studentId,
        studentName,
        studentEmail,
        progress,
        examScore,
        completionDate,
      ];

  factory EligibleStudent.fromJson(Map<String, dynamic> json) {
    return EligibleStudent(
      studentId: json['student_id'] ?? '',
      studentName: json['student_name'] ?? '',
      studentEmail: json['student_email'] ?? '',
      progress: json['progress'] ?? 0,
      examScore: json['exam_score'],
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
    );
  }
}
