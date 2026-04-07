import 'package:equatable/equatable.dart';

class Exam extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final int? totalQuestions;
  final int? passingScore;
  final int? durationMinutes;
  final ExamStatus status;
  final bool allowRetake;
  final int maxAttempts;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Exam({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.totalQuestions,
    this.passingScore,
    this.durationMinutes,
    this.status = ExamStatus.draft,
    this.allowRetake = true,
    this.maxAttempts = 3,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        totalQuestions,
        passingScore,
        durationMinutes,
        status,
        allowRetake,
        maxAttempts,
        createdAt,
        updatedAt,
      ];

  Exam copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    int? totalQuestions,
    int? passingScore,
    int? durationMinutes,
    ExamStatus? status,
    bool? allowRetake,
    int? maxAttempts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exam(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      passingScore: passingScore ?? this.passingScore,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      allowRetake: allowRetake ?? this.allowRetake,
      maxAttempts: maxAttempts ?? this.maxAttempts,
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
      'total_questions': totalQuestions,
      'passing_score': passingScore,
      'duration_minutes': durationMinutes,
      'status': status.name,
      'allow_retake': allowRetake,
      'max_attempts': maxAttempts,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      totalQuestions: json['total_questions'],
      passingScore: json['passing_score'],
      durationMinutes: json['duration_minutes'],
      status: ExamStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'draft'),
        orElse: () => ExamStatus.draft,
      ),
      allowRetake: json['allow_retake'] ?? true,
      maxAttempts: json['max_attempts'] ?? 3,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum ExamStatus { draft, published }

class ExamQuestion extends Equatable {
  final String id;
  final String examId;
  final String questionText;
  final QuestionType questionType;
  final List<String>? options;
  final String? correctAnswer;
  final int points;
  final int? orderNumber;
  final DateTime createdAt;

  const ExamQuestion({
    required this.id,
    required this.examId,
    required this.questionText,
    required this.questionType,
    this.options,
    this.correctAnswer,
    this.points = 1,
    this.orderNumber,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        examId,
        questionText,
        questionType,
        options,
        correctAnswer,
        points,
        orderNumber,
        createdAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'question_text': questionText,
      'question_type': questionType.name,
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
      questionType: QuestionType.values.firstWhere(
        (e) => e.name == (json['question_type'] ?? 'multiple_choice'),
        orElse: () => QuestionType.multipleChoice,
      ),
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
      correctAnswer: json['correct_answer'],
      points: json['points'] ?? 1,
      orderNumber: json['order_number'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum QuestionType { multipleChoice, trueFalse, essay, shortAnswer }

class ExamResult extends Equatable {
  final String id;
  final String examId;
  final String studentId;
  final int? score;
  final int? totalScore;
  final double? percentage;
  final bool? passed;
  final int attemptNumber;
  final DateTime? completedAt;
  final Map<String, dynamic>? answers;
  final DateTime createdAt;

  const ExamResult({
    required this.id,
    required this.examId,
    required this.studentId,
    this.score,
    this.totalScore,
    this.percentage,
    this.passed,
    this.attemptNumber = 1,
    this.completedAt,
    this.answers,
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
        completedAt,
        answers,
        createdAt,
      ];

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'] ?? '',
      examId: json['exam_id'] ?? '',
      studentId: json['student_id'] ?? '',
      score: json['score'],
      totalScore: json['total_score'],
      percentage: (json['percentage'] as num?)?.toDouble(),
      passed: json['passed'],
      attemptNumber: json['attempt_number'] ?? 1,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      answers: json['answers'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
