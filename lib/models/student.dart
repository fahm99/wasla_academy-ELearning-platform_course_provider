import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final DateTime enrollmentDate;
  final List<String> enrolledCourses;
  final List<String> certificateIds;
  final StudentStatus status;

  const Student({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.enrollmentDate,
    this.enrolledCourses = const [],
    this.certificateIds = const [],
    this.status = StudentStatus.active,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatar,
        enrollmentDate,
        enrolledCourses,
        certificateIds,
        status
      ];

  Student copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    DateTime? enrollmentDate,
    List<String>? enrolledCourses,
    List<String>? certificateIds,
    StudentStatus? status,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      certificateIds: certificateIds ?? this.certificateIds,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'enrolledCourses': enrolledCourses,
      'certificateIds': certificateIds,
      'status': status.name,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      enrollmentDate: DateTime.parse(json['enrollmentDate']),
      enrolledCourses: List<String>.from(json['enrolledCourses'] ?? []),
      certificateIds: List<String>.from(json['certificateIds'] ?? []),
      status: StudentStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }
}

enum StudentStatus { active, inactive, suspended }
