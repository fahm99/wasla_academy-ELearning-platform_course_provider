import 'package:course_provider/data/services/supabase_service.dart';
import '../models/exam.dart' hide ExamQuestion, ExamResult;
import '../models/exam_question.dart';
import '../models/exam_result.dart';
import '../../core/config/supabase_config.dart';

/// خدمة إدارة الامتحانات
class ExamService {
  final SupabaseService _supabaseService = SupabaseService();

  /// الحصول على امتحانات الكورس
  Future<List<Exam>> getCourseExams(String courseId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.examsTable,
        filters: {'course_id': courseId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((e) => Exam.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// الحصول على امتحان واحد
  Future<Exam?> getExam(String examId) async {
    try {
      final data = await _supabaseService.getOne(
        SupabaseConfig.examsTable,
        examId,
      );
      if (data == null) return null;
      return Exam.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// إنشاء امتحان جديد
  Future<Exam?> createExam({
    required String courseId,
    required String title,
    String? description,
    int? totalQuestions,
    int? passingScore,
    int? durationMinutes,
    bool allowRetake = true,
    int maxAttempts = 3,
  }) async {
    try {
      final data = await _supabaseService.insert(
        SupabaseConfig.examsTable,
        {
          'course_id': courseId,
          'title': title,
          'description': description,
          'total_questions': totalQuestions,
          'passing_score': passingScore,
          'duration_minutes': durationMinutes,
          'allow_retake': allowRetake,
          'max_attempts': maxAttempts,
        },
      );
      return Exam.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// تحديث الامتحان
  Future<bool> updateExam({
    required String examId,
    String? title,
    String? description,
    int? totalQuestions,
    int? passingScore,
    int? durationMinutes,
    ExamStatus? status,
    bool? allowRetake,
    int? maxAttempts,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (totalQuestions != null) {
        updateData['total_questions'] = totalQuestions;
      }
      if (passingScore != null) updateData['passing_score'] = passingScore;
      if (durationMinutes != null) {
        updateData['duration_minutes'] = durationMinutes;
      }
      if (status != null) updateData['status'] = status.name;
      if (allowRetake != null) updateData['allow_retake'] = allowRetake;
      if (maxAttempts != null) updateData['max_attempts'] = maxAttempts;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabaseService.update(
        SupabaseConfig.examsTable,
        examId,
        updateData,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف الامتحان
  Future<bool> deleteExam(String examId) async {
    try {
      await _supabaseService.delete(SupabaseConfig.examsTable, examId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// نشر الامتحان
  Future<bool> publishExam(String examId) async {
    return updateExam(examId: examId, status: ExamStatus.published);
  }

  // ========== أسئلة الامتحان ==========

  /// الحصول على أسئلة الامتحان
  Future<List<ExamQuestion>> getExamQuestions(String examId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.examQuestionsTable,
        filters: {'exam_id': examId},
        orderBy: 'order_number',
        ascending: true,
      );
      return data.map((e) => ExamQuestion.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// إضافة سؤال
  Future<ExamQuestion?> addQuestion({
    required String examId,
    required String questionText,
    required QuestionType questionType,
    List<String>? options,
    String? correctAnswer,
    int points = 1,
    int? orderNumber,
  }) async {
    try {
      final data = await _supabaseService.insert(
        SupabaseConfig.examQuestionsTable,
        {
          'exam_id': examId,
          'question_text': questionText,
          'question_type': questionType.toDbString(),
          'options': options,
          'correct_answer': correctAnswer,
          'points': points,
          'order_number': orderNumber,
        },
      );
      return ExamQuestion.fromJson(data);
    } catch (e) {
      print('Error adding question: $e');
      return null;
    }
  }

  /// تحديث سؤال
  Future<bool> updateQuestion({
    required String questionId,
    String? questionText,
    QuestionType? questionType,
    List<String>? options,
    String? correctAnswer,
    int? points,
    int? orderNumber,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (questionText != null) updateData['question_text'] = questionText;
      if (questionType != null) {
        updateData['question_type'] = questionType.toDbString();
      }
      if (options != null) updateData['options'] = options;
      if (correctAnswer != null) updateData['correct_answer'] = correctAnswer;
      if (points != null) updateData['points'] = points;
      if (orderNumber != null) updateData['order_number'] = orderNumber;

      await _supabaseService.update(
        SupabaseConfig.examQuestionsTable,
        questionId,
        updateData,
      );
      return true;
    } catch (e) {
      print('Error updating question: $e');
      return false;
    }
  }

  /// حذف سؤال
  Future<bool> deleteQuestion(String questionId) async {
    try {
      await _supabaseService.delete(
        SupabaseConfig.examQuestionsTable,
        questionId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== نتائج الامتحان ==========

  /// الحصول على نتائج الامتحان
  Future<List<ExamResult>> getExamResults(String examId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.examResultsTable,
        filters: {'exam_id': examId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((e) => ExamResult.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
