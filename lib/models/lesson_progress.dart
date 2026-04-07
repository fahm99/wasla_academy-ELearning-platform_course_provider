import 'package:equatable/equatable.dart';

class LessonProgress extends Equatable {
  final String id;
  final String studentId;
  final String lessonId;
  final bool isCompleted;
  final int watchedDuration;
  final DateTime? completedAt;

  const LessonProgress({
    required this.id,
    required this.studentId,
    required this.lessonId,
    this.isCompleted = false,
    this.watchedDuration = 0,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        lessonId,
        isCompleted,
        watchedDuration,
        completedAt,
      ];

  LessonProgress copyWith({
    String? id,
    String? studentId,
    String? lessonId,
    bool? isCompleted,
    int? watchedDuration,
    DateTime? completedAt,
  }) {
    return LessonProgress(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      lessonId: lessonId ?? this.lessonId,
      isCompleted: isCompleted ?? this.isCompleted,
      watchedDuration: watchedDuration ?? this.watchedDuration,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'lesson_id': lessonId,
      'is_completed': isCompleted,
      'watched_duration': watchedDuration,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      lessonId: json['lesson_id'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      watchedDuration: json['watched_duration'] ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }
}
