import 'package:equatable/equatable.dart';

class LessonResource extends Equatable {
  final String id;
  final String lessonId;
  final String fileName;
  final String fileUrl;
  final FileType fileType;
  final int? fileSize;
  final DateTime createdAt;

  const LessonResource({
    required this.id,
    required this.lessonId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.fileSize,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        lessonId,
        fileName,
        fileUrl,
        fileType,
        fileSize,
        createdAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType.name,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory LessonResource.fromJson(Map<String, dynamic> json) {
    return LessonResource(
      id: json['id'] ?? '',
      lessonId: json['lesson_id'] ?? '',
      fileName: json['file_name'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileType: FileType.values.firstWhere(
        (e) => e.name == (json['file_type'] ?? 'other'),
        orElse: () => FileType.other,
      ),
      fileSize: json['file_size'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum FileType { pdf, doc, image, zip, other }
