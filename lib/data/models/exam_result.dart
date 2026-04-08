import 'package:equatable/equatable.dart';

/// نموذج نتيجة الامتحان
class ExamResult extends Equatable {
  final String id;
  final String examId;
  final String studentId;
  final int score; // عدد الإجابات الصحيحة
  final int totalScore; // إجمالي النقاط
  final double percentage; // النسبة المئوية
  final bool passed; // ناجح أم راسب
  final int attemptNumber; // رقم المحاولة
  final Map<String, String>
      answers; // إجابات الطالب: {questionId: selectedOption}
  final DateTime completedAt;
  final DateTime createdAt;

  const ExamResult({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.score,
    required this.totalScore,
    required this.percentage,
    required this.passed,
    required this.attemptNumber,
    required this.answers,
    required this.completedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        examId,
        studentId,
        score,
        totalScore,
        percentage,
        passed,
        attemptNumber,
        answers,
        completedAt,
        createdAt,
      ];

  ExamResult copyWith({
    String? id,
    String? examId,
    String? studentId,
    int? score,
    int? totalScore,
    double? percentage,
    bool? passed,
    int? attemptNumber,
    Map<String, String>? answers,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return ExamResult(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      studentId: studentId ?? this.studentId,
      score: score ?? this.score,
      totalScore: totalScore ?? this.totalScore,
      percentage: percentage ?? this.percentage,
      passed: passed ?? this.passed,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      answers: answers ?? this.answers,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'student_id': studentId,
      'score': score,
      'total_score': totalScore,
      'percentage': percentage,
      'passed': passed,
      'attempt_number': attemptNumber,
      'answers': answers,
      'completed_at': completedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'] ?? '',
      examId: json['exam_id'] ?? '',
      studentId: json['student_id'] ?? '',
      score: json['score'] ?? 0,
      totalScore: json['total_score'] ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      passed: json['passed'] ?? false,
      attemptNumber: json['attempt_number'] ?? 1,
      answers: json['answers'] != null
          ? Map<String, String>.from(json['answers'])
          : {},
      completedAt: DateTime.parse(
          json['completed_at'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
