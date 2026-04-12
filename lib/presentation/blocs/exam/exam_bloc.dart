import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/exam_service.dart';
import '../../../data/models/exam.dart' hide ExamQuestion;
import 'exam_event.dart';
import 'exam_state.dart';

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final ExamService _examService;

  ExamBloc({ExamService? examService})
      : _examService = examService ?? ExamService(),
        super(ExamInitial()) {
    on<LoadCourseExams>(_onLoadCourseExams);
    on<LoadExamDetails>(_onLoadExamDetails);
    on<CreateExam>(_onCreateExam);
    on<UpdateExam>(_onUpdateExam);
    on<DeleteExam>(_onDeleteExam);
    on<PublishExam>(_onPublishExam);
    on<LoadExamQuestions>(_onLoadExamQuestions);
    on<AddQuestion>(_onAddQuestion);
    on<UpdateQuestion>(_onUpdateQuestion);
    on<DeleteQuestion>(_onDeleteQuestion);
    on<LoadExamResults>(_onLoadExamResults);
  }

  Future<void> _onLoadCourseExams(
    LoadCourseExams event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    try {
      final exams = await _examService.getCourseExams(event.courseId);
      emit(ExamsLoaded(exams));
    } catch (e) {
      emit(ExamError('فشل تحميل الامتحانات: ${e.toString()}'));
    }
  }

  Future<void> _onLoadExamDetails(
    LoadExamDetails event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    try {
      final exam = await _examService.getExam(event.examId);
      if (exam == null) {
        emit(const ExamError('الامتحان غير موجود'));
        return;
      }
      final questions = await _examService.getExamQuestions(event.examId);
      emit(ExamDetailsLoaded(exam: exam, questions: questions));
    } catch (e) {
      emit(ExamError('فشل تحميل تفاصيل الامتحان: ${e.toString()}'));
    }
  }

  Future<void> _onCreateExam(
    CreateExam event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    try {
      final exam = await _examService.createExam(
        courseId: event.courseId,
        title: event.title,
        description: event.description,
        totalQuestions: event.totalQuestions,
        passingScore: event.passingScore,
        durationMinutes: event.durationMinutes,
        allowRetake: event.allowRetake,
        maxAttempts: event.maxAttempts,
      );

      if (exam != null) {
        emit(const ExamOperationSuccess('تم إنشاء الامتحان بنجاح'));
        add(LoadCourseExams(event.courseId));
      } else {
        emit(const ExamError('فشل إنشاء الامتحان'));
      }
    } catch (e) {
      emit(ExamError('فشل إنشاء الامتحان: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateExam(
    UpdateExam event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    try {
      final success = await _examService.updateExam(
        examId: event.examId,
        title: event.title,
        description: event.description,
        totalQuestions: event.totalQuestions,
        passingScore: event.passingScore,
        durationMinutes: event.durationMinutes,
        status: event.status,
        allowRetake: event.allowRetake,
        maxAttempts: event.maxAttempts,
      );

      if (success) {
        emit(const ExamOperationSuccess('تم تحديث الامتحان بنجاح'));
        add(LoadExamDetails(event.examId));
      } else {
        emit(const ExamError('فشل تحديث الامتحان'));
      }
    } catch (e) {
      emit(ExamError('فشل تحديث الامتحان: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteExam(
    DeleteExam event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    try {
      final success = await _examService.deleteExam(event.examId);
      if (success) {
        emit(const ExamOperationSuccess('تم حذف الامتحان بنجاح'));
      } else {
        emit(const ExamError('فشل حذف الامتحان'));
      }
    } catch (e) {
      emit(ExamError('فشل حذف الامتحان: ${e.toString()}'));
    }
  }

  Future<void> _onPublishExam(
    PublishExam event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    try {
      final success = await _examService.publishExam(event.examId);
      if (success) {
        emit(const ExamOperationSuccess('تم نشر الامتحان بنجاح'));
        add(LoadExamDetails(event.examId));
      } else {
        emit(const ExamError('فشل نشر الامتحان'));
      }
    } catch (e) {
      emit(ExamError('فشل نشر الامتحان: ${e.toString()}'));
    }
  }

  Future<void> _onLoadExamQuestions(
    LoadExamQuestions event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    try {
      final questions = await _examService.getExamQuestions(event.examId);
      emit(ExamQuestionsLoaded(questions));
    } catch (e) {
      emit(ExamError('فشل تحميل الأسئلة: ${e.toString()}'));
    }
  }

  Future<void> _onAddQuestion(
    AddQuestion event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    try {
      final question = await _examService.addQuestion(
        examId: event.examId,
        questionText: event.questionText,
        questionType: QuestionType.multipleChoice,
        options: event.options,
        correctAnswer: event.correctAnswer,
        points: event.points,
        orderNumber: event.orderNumber,
      );

      if (question != null) {
        emit(const ExamOperationSuccess('تم إضافة السؤال بنجاح'));
        add(LoadExamQuestions(event.examId));
      } else {
        emit(const ExamError('فشل إضافة السؤال'));
      }
    } catch (e) {
      emit(ExamError('فشل إضافة السؤال: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateQuestion(
    UpdateQuestion event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    try {
      final success = await _examService.updateQuestion(
        questionId: event.questionId,
        questionText: event.questionText,
        options: event.options,
        correctAnswer: event.correctAnswer,
        points: event.points,
        orderNumber: event.orderNumber,
      );

      if (success) {
        emit(const ExamOperationSuccess('تم تحديث السؤال بنجاح'));
      } else {
        emit(const ExamError('فشل تحديث السؤال'));
      }
    } catch (e) {
      emit(ExamError('فشل تحديث السؤال: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteQuestion(
    DeleteQuestion event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    try {
      final success = await _examService.deleteQuestion(event.questionId);
      if (success) {
        emit(const ExamOperationSuccess('تم حذف السؤال بنجاح'));
      } else {
        emit(const ExamError('فشل حذف السؤال'));
      }
    } catch (e) {
      emit(ExamError('فشل حذف السؤال: ${e.toString()}'));
    }
  }

  Future<void> _onLoadExamResults(
    LoadExamResults event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    try {
      final results = await _examService.getExamResults(event.examId);
      emit(ExamResultsLoaded(results));
    } catch (e) {
      emit(ExamError('فشل تحميل النتائج: ${e.toString()}'));
    }
  }
}
