import 'package:equatable/equatable.dart';

/// نموذج سؤال الامتحان (MCQ فقط)
class ExamQuestion extends Equatable {
  final String id;
  final String examId;
  final String questionText;
  final List<String> options; // 4 خيارات: A, B, C, D
  final String correctAnswer; // الإجابة الصحيحة: 'A', 'B', 'C', أو 'D'
  final int points;
  final int orderNumber;
  final DateTime createdAt;

  const ExamQuestion({
    required this.id,
    required this.examId,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.points = 1,
    required this.orderNumber,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        examId,
        questionText,
        options,
        correctAnswer,
        points,
        orderNumber,
        createdAt,
      ];

  ExamQuestion copyWith({
    String? id,
    String? examId,
    String? questionText,
    List<String>? options,
    String? correctAnswer,
    int? points,
    int? orderNumber,
    DateTime? createdAt,
  }) {
    return ExamQuestion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      points: points ?? this.points,
      orderNumber: orderNumber ?? this.orderNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'question_text': questionText,
      'options': options,
      'correct_answer': correctAnswer,
      'points': points,
      'order_number': orderNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      id: json['id'] ?? '',
      examId: json['exam_id'] ?? '',
      questionText: json['question_text'] ?? '',
      options:
          json['options'] != null ? List<String>.from(json['options']) : [],
      correctAnswer: json['correct_answer'] ?? '',
      points: json['points'] ?? 1,
      orderNumber: json['order_number'] ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
