import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String courseId;
  final String studentId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Review({
    required this.id,
    required this.courseId,
    required this.studentId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        studentId,
        rating,
        comment,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'student_id': studentId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      studentId: json['student_id'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
