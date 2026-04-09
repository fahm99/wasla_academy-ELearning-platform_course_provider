import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? profileImageUrl;
  final UserType userType;
  final String? bio;
  final double rating;
  final bool isActive;
  final bool isVerified;

  // حقول مقدم الخدمة
  final int? coursesCount;
  final int? studentsCount;
  final double? totalEarnings;
  final Map<String, dynamic>? bankAccount;
  final String? specialization;

  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.profileImageUrl,
    required this.userType,
    this.bio,
    this.rating = 0.0,
    this.isActive = true,
    this.isVerified = false,
    this.coursesCount,
    this.studentsCount,
    this.totalEarnings,
    this.bankAccount,
    this.specialization,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatarUrl,
        profileImageUrl,
        userType,
        bio,
        rating,
        isActive,
        isVerified,
        coursesCount,
        studentsCount,
        totalEarnings,
        bankAccount,
        specialization,
        createdAt,
        updatedAt,
      ];

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? profileImageUrl,
    UserType? userType,
    String? bio,
    double? rating,
    bool? isActive,
    bool? isVerified,
    int? coursesCount,
    int? studentsCount,
    double? totalEarnings,
    Map<String, dynamic>? bankAccount,
    String? specialization,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      userType: userType ?? this.userType,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      coursesCount: coursesCount ?? this.coursesCount,
      studentsCount: studentsCount ?? this.studentsCount,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      bankAccount: bankAccount ?? this.bankAccount,
      specialization: specialization ?? this.specialization,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'profile_image_url': profileImageUrl,
      'user_type': userType.name,
      'bio': bio,
      'rating': rating,
      'is_active': isActive,
      'is_verified': isVerified,
      'courses_count': coursesCount,
      'students_count': studentsCount,
      'total_earnings': totalEarnings,
      'bank_account': bankAccount,
      'specialization': specialization,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      profileImageUrl: json['profile_image_url'],
      userType: UserType.values.firstWhere(
        (e) => e.name == (json['user_type'] ?? 'provider'),
        orElse: () => UserType.provider,
      ),
      bio: json['bio'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      coursesCount: json['courses_count'],
      studentsCount: json['students_count'],
      totalEarnings: (json['total_earnings'] as num?)?.toDouble(),
      bankAccount: json['bank_account'],
      specialization: json['specialization'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum UserType { provider }
