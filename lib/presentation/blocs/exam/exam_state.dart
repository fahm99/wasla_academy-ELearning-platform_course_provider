import 'package:equatable/equatable.dart';
import '../../../data/models/exam.dart' hide ExamQuestion, ExamResult;
import '../../../data/models/exam_question.dart';
import '../../../data/models/exam_result.dart';

abstract class ExamState extends Equatable {
  const ExamState();

  @override
  List<Object?> get props => [];
}

class ExamInitial extends ExamState {}

class ExamLoading extends ExamState {}

class ExamsLoaded extends ExamState {
  final List<Exam> exams;

  const ExamsLoaded(this.exams);

  @override
  List<Object?> get props => [exams];
}

class ExamDetailsLoaded extends ExamState {
  final Exam exam;
  final List<ExamQuestion> questions;

  const ExamDetailsLoaded({
    required this.exam,
    required this.questions,
  });

  @override
  List<Object?> get props => [exam, questions];
}

class ExamQuestionsLoaded extends ExamState {
  final List<ExamQuestion> questions;

  const ExamQuestionsLoaded(this.questions);

  @override
  List<Object?> get props => [questions];
}

class ExamResultsLoaded extends ExamState {
  final List<ExamResult> results;

  const ExamResultsLoaded(this.results);

  @override
  List<Object?> get props => [results];
}

class ExamOperationSuccess extends ExamState {
  final String message;

  const ExamOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ExamError extends ExamState {
  final String message;

  const ExamError(this.message);

  @override
  List<Object?> get props => [message];
}
