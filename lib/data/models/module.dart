import 'package:equatable/equatable.dart';

class Module extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final int orderNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Module({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.orderNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        orderNumber,
        createdAt,
        updatedAt,
      ];

  Module copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    int? orderNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Module(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderNumber: orderNumber ?? this.orderNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'order_number': orderNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      orderNumber: json['order_number'] ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
