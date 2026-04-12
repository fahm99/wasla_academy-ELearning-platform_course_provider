import 'package:equatable/equatable.dart';
import '../../../data/models/exam.dart';

abstract class ExamEvent extends Equatable {
  const ExamEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourseExams extends ExamEvent {
  final String courseId;

  const LoadCourseExams(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class LoadExamDetails extends ExamEvent {
  final String examId;

  const LoadExamDetails(this.examId);

  @override
  List<Object?> get props => [examId];
}

class CreateExam extends ExamEvent {
  final String courseId;
  final String title;
  final String? description;
  final int? totalQuestions;
  final int? passingScore;
  final int? durationMinutes;
  final bool allowRetake;
  final int maxAttempts;

  const CreateExam({
    required this.courseId,
    required this.title,
    this.description,
    this.totalQuestions,
    this.passingScore,
    this.durationMinutes,
    this.allowRetake = true,
    this.maxAttempts = 3,
  });

  @override
  List<Object?> get props => [
        courseId,
        title,
        description,
        totalQuestions,
        passingScore,
        durationMinutes,
        allowRetake,
        maxAttempts,
      ];
}

class UpdateExam extends ExamEvent {
  final String examId;
  final String? title;
  final String? description;
  final int? totalQuestions;
  final int? passingScore;
  final int? durationMinutes;
  final ExamStatus? status;
  final bool? allowRetake;
  final int? maxAttempts;

  const UpdateExam({
    required this.examId,
    this.title,
    this.description,
    this.totalQuestions,
    this.passingScore,
    this.durationMinutes,
    this.status,
    this.allowRetake,
    this.maxAttempts,
  });

  @override
  List<Object?> get props => [
        examId,
        title,
        description,
        totalQuestions,
        passingScore,
        durationMinutes,
        status,
        allowRetake,
        maxAttempts,
      ];
}

class DeleteExam extends ExamEvent {
  final String examId;

  const DeleteExam(this.examId);

  @override
  List<Object?> get props => [examId];
}

class PublishExam extends ExamEvent {
  final String examId;

  const PublishExam(this.examId);

  @override
  List<Object?> get props => [examId];
}

class LoadExamQuestions extends ExamEvent {
  final String examId;

  const LoadExamQuestions(this.examId);

  @override
  List<Object?> get props => [examId];
}

class AddQuestion extends ExamEvent {
  final String examId;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final int points;
  final int orderNumber;

  const AddQuestion({
    required this.examId,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.points = 1,
    required this.orderNumber,
  });

  @override
  List<Object?> get props => [
        examId,
        questionText,
        options,
        correctAnswer,
        points,
        orderNumber,
      ];
}

class UpdateQuestion extends ExamEvent {
  final String questionId;
  final String? questionText;
  final List<String>? options;
  final String? correctAnswer;
  final int? points;
  final int? orderNumber;

  const UpdateQuestion({
    required this.questionId,
    this.questionText,
    this.options,
    this.correctAnswer,
    this.points,
    this.orderNumber,
  });

  @override
  List<Object?> get props => [
        questionId,
        questionText,
        options,
        correctAnswer,
        points,
        orderNumber,
      ];
}

class DeleteQuestion extends ExamEvent {
  final String questionId;

  const DeleteQuestion(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

class LoadExamResults extends ExamEvent {
  final String examId;

  const LoadExamResults(this.examId);

  @override
  List<Object?> get props => [examId];
}
