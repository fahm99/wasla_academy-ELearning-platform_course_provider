import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? profileImage;
  final UserType type;
  final DateTime createdAt;
  final bool isActive;
  final int? coursesCount;
  final int? studentsCount;
  final double? rating;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.profileImage,
    required this.type,
    required this.createdAt,
    this.isActive = true,
    this.coursesCount,
    this.studentsCount,
    this.rating,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatar,
        profileImage,
        type,
        createdAt,
        isActive,
        coursesCount,
        studentsCount,
        rating,
      ];

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? profileImage,
    UserType? type,
    DateTime? createdAt,
    bool? isActive,
    int? coursesCount,
    int? studentsCount,
    double? rating,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      profileImage: profileImage ?? this.profileImage,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      coursesCount: coursesCount ?? this.coursesCount,
      studentsCount: studentsCount ?? this.studentsCount,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'profileImage': profileImage,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'coursesCount': coursesCount,
      'studentsCount': studentsCount,
      'rating': rating,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      profileImage: json['profileImage'],
      type: UserType.values.firstWhere((e) => e.name == json['type']),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      coursesCount: json['coursesCount'],
      studentsCount: json['studentsCount'],
      rating: json['rating']?.toDouble(),
    );
  }
}

enum UserType { admin, provider, student }
