import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? videoUrl;
  final String? content;
  final int duration; // بالدقائق
  final int order;
  final bool isCompleted;
  final DateTime createdAt;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    this.videoUrl,
    this.content,
    required this.duration,
    required this.order,
    this.isCompleted = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        videoUrl,
        content,
        duration,
        order,
        isCompleted,
        createdAt
      ];

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? content,
    int? duration,
    int? order,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      content: content ?? this.content,
      duration: duration ?? this.duration,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'content': content,
      'duration': duration,
      'order': order,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['videoUrl'],
      content: json['content'],
      duration: json['duration'] ?? 0,
      order: json['order'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
