import 'package:equatable/equatable.dart';

class Enrollment extends Equatable {
  final String id;
  final String studentId;
  final String courseId;
  final DateTime enrollmentDate;
  final int completionPercentage;
  final EnrollmentStatus status;
  final DateTime? lastAccessed;
  final String? certificateId;

  const Enrollment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.enrollmentDate,
    this.completionPercentage = 0,
    this.status = EnrollmentStatus.active,
    this.lastAccessed,
    this.certificateId,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        courseId,
        enrollmentDate,
        completionPercentage,
        status,
        lastAccessed,
        certificateId,
      ];

  Enrollment copyWith({
    String? id,
    String? studentId,
    String? courseId,
    DateTime? enrollmentDate,
    int? completionPercentage,
    EnrollmentStatus? status,
    DateTime? lastAccessed,
    String? certificateId,
  }) {
    return Enrollment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      status: status ?? this.status,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      certificateId: certificateId ?? this.certificateId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'course_id': courseId,
      'enrollment_date': enrollmentDate.toIso8601String(),
      'completion_percentage': completionPercentage,
      'status': status.name,
      'last_accessed': lastAccessed?.toIso8601String(),
      'certificate_id': certificateId,
    };
  }

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      courseId: json['course_id'] ?? '',
      enrollmentDate: DateTime.parse(
          json['enrollment_date'] ?? DateTime.now().toIso8601String()),
      completionPercentage: json['completion_percentage'] ?? 0,
      status: EnrollmentStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'active'),
        orElse: () => EnrollmentStatus.active,
      ),
      lastAccessed: json['last_accessed'] != null
          ? DateTime.parse(json['last_accessed'])
          : null,
      certificateId: json['certificate_id'],
    );
  }
}

enum EnrollmentStatus { active, completed, dropped }
