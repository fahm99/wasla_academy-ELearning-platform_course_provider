import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final String id;
  final String moduleId;
  final String courseId;
  final String title;
  final String? description;
  final int orderNumber;
  final LessonType? lessonType;
  final String? videoUrl;
  final int? videoDuration; // بالثواني
  final String? content;
  final bool isFree;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.courseId,
    required this.title,
    this.description,
    required this.orderNumber,
    this.lessonType,
    this.videoUrl,
    this.videoDuration,
    this.content,
    this.isFree = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        moduleId,
        courseId,
        title,
        description,
        orderNumber,
        lessonType,
        videoUrl,
        videoDuration,
        content,
        isFree,
        createdAt,
        updatedAt,
      ];

  Lesson copyWith({
    String? id,
    String? moduleId,
    String? courseId,
    String? title,
    String? description,
    int? orderNumber,
    LessonType? lessonType,
    String? videoUrl,
    int? videoDuration,
    String? content,
    bool? isFree,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderNumber: orderNumber ?? this.orderNumber,
      lessonType: lessonType ?? this.lessonType,
      videoUrl: videoUrl ?? this.videoUrl,
      videoDuration: videoDuration ?? this.videoDuration,
      content: content ?? this.content,
      isFree: isFree ?? this.isFree,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'course_id': courseId,
      'title': title,
      'description': description,
      'order_number': orderNumber,
      'lesson_type': lessonType?.name,
      'video_url': videoUrl,
      'video_duration': videoDuration,
      'content': content,
      'is_free': isFree,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      moduleId: json['module_id'] ?? '',
      courseId: json['course_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      orderNumber: json['order_number'] ?? 0,
      lessonType: json['lesson_type'] != null
          ? LessonType.values.firstWhere(
              (e) => e.name == json['lesson_type'],
              orElse: () => LessonType.text,
            )
          : null,
      videoUrl: json['video_url'],
      videoDuration: json['video_duration'],
      content: json['content'],
      isFree: json['is_free'] ?? false,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum LessonType { video, text, file, quiz }
