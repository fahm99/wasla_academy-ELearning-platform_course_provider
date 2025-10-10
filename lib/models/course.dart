import 'package:equatable/equatable.dart';
import 'lesson.dart';

class Course extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? image;
  final String? imageUrl;
  final String providerId;
  final String providerName;
  final double price;
  final bool isFree;
  final CourseStatus status;
  final CourseLevel level;
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final int duration; // بالدقائق
  final int studentsCount;
  final double rating;
  final int reviewsCount;
  final List<Lesson> lessons;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.imageUrl,
    required this.providerId,
    required this.providerName,
    required this.price,
    this.isFree = false,
    this.status = CourseStatus.draft,
    required this.level,
    required this.category,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    required this.duration,
    this.studentsCount = 0,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.lessons = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        image,
        imageUrl,
        providerId,
        providerName,
        price,
        isFree,
        status,
        level,
        category,
        tags,
        createdAt,
        updatedAt,
        publishedAt,
        duration,
        studentsCount,
        rating,
        reviewsCount,
        lessons
      ];

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    String? imageUrl,
    String? providerId,
    String? providerName,
    double? price,
    bool? isFree,
    CourseStatus? status,
    CourseLevel? level,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    int? duration,
    int? studentsCount,
    double? rating,
    int? reviewsCount,
    List<Lesson>? lessons,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      status: status ?? this.status,
      level: level ?? this.level,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      duration: duration ?? this.duration,
      studentsCount: studentsCount ?? this.studentsCount,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      lessons: lessons ?? this.lessons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'imageUrl': imageUrl,
      'providerId': providerId,
      'providerName': providerName,
      'price': price,
      'isFree': isFree,
      'status': status.name,
      'level': level.name,
      'category': category,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'duration': duration,
      'studentsCount': studentsCount,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      imageUrl: json['imageUrl'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      price: json['price']?.toDouble() ?? 0.0,
      isFree: json['isFree'] ?? false,
      status: CourseStatus.values.firstWhere((e) => e.name == json['status']),
      level: CourseLevel.values.firstWhere((e) => e.name == json['level']),
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      duration: json['duration'] ?? 0,
      studentsCount: json['studentsCount'] ?? 0,
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewsCount: json['reviewsCount'] ?? 0,
      lessons:
          (json['lessons'] as List?)?.map((l) => Lesson.fromJson(l)).toList() ??
              [],
    );
  }
}

enum CourseStatus { draft, pending, published, rejected, archived }

enum CourseLevel { beginner, intermediate, advanced }
