import 'package:equatable/equatable.dart';

class Course extends Equatable {
  final String id;
  final String title;
  final String description;
  final String providerId;
  final String? category;
  final CourseLevel? level;
  final double price;
  final String currency;
  final int? durationHours;
  final String? thumbnailUrl;
  final String? coverImageUrl;
  final CourseStatus status;
  final int studentsCount;
  final double rating;
  final int reviewsCount;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.providerId,
    this.category,
    this.level,
    this.price = 0,
    this.currency = 'SAR',
    this.durationHours,
    this.thumbnailUrl,
    this.coverImageUrl,
    this.status = CourseStatus.draft,
    this.studentsCount = 0,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        providerId,
        category,
        level,
        price,
        currency,
        durationHours,
        thumbnailUrl,
        coverImageUrl,
        status,
        studentsCount,
        rating,
        reviewsCount,
        isFeatured,
        createdAt,
        updatedAt,
      ];

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? providerId,
    String? category,
    CourseLevel? level,
    double? price,
    String? currency,
    int? durationHours,
    String? thumbnailUrl,
    String? coverImageUrl,
    CourseStatus? status,
    int? studentsCount,
    double? rating,
    int? reviewsCount,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      providerId: providerId ?? this.providerId,
      category: category ?? this.category,
      level: level ?? this.level,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      durationHours: durationHours ?? this.durationHours,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status ?? this.status,
      studentsCount: studentsCount ?? this.studentsCount,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'provider_id': providerId,
      'category': category,
      'level': level?.name,
      'price': price,
      'currency': currency,
      'duration_hours': durationHours,
      'thumbnail_url': thumbnailUrl,
      'cover_image_url': coverImageUrl,
      'status': status.name,
      'students_count': studentsCount,
      'rating': rating,
      'reviews_count': reviewsCount,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      providerId: json['provider_id'] ?? '',
      category: json['category'],
      level: json['level'] != null
          ? CourseLevel.values.firstWhere(
              (e) => e.name == json['level'],
              orElse: () => CourseLevel.beginner,
            )
          : null,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'SAR',
      durationHours: json['duration_hours'],
      thumbnailUrl: json['thumbnail_url'],
      coverImageUrl: json['cover_image_url'],
      status: CourseStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'draft'),
        orElse: () => CourseStatus.draft,
      ),
      studentsCount: json['students_count'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum CourseStatus { draft, pending_review, published, archived }

enum CourseLevel { beginner, intermediate, advanced }
