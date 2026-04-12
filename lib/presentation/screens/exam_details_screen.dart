import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exam.dart';
import '../../data/models/exam_question.dart' as eq;
import '../blocs/exam/exam_bloc.dart';
import '../blocs/exam/exam_event.dart';
import '../blocs/exam/exam_state.dart';
import '../widgets/question_form_dialog.dart';

class ExamDetailsScreen extends StatelessWidget {
  final Exam exam;

  const ExamDetailsScreen({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExamBloc()..add(LoadExamDetails(exam.id)),
      child: _ExamDetailsView(exam: exam),
    );
  }
}

class _ExamDetailsView extends StatelessWidget {
  final Exam exam;

  const _ExamDetailsView({required this.exam});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          backgroundColor: AppTheme.darkBlue,
          foregroundColor: AppTheme.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'العودة',
          ),
          title: const Text('تفاصيل الامتحان'),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                // TODO: Navigate to results screen
              },
              tooltip: 'النتائج',
            ),
          ],
        ),
      body: BlocConsumer<ExamBloc, ExamState>(
        listener: (context, state) {
          if (state is ExamError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is ExamOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
            context.read<ExamBloc>().add(LoadExamDetails(exam.id));
          }
        },
        builder: (context, state) {
          if (state is ExamLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExamDetailsLoaded) {
            return _buildContent(
                context, state.exam, state.questions.cast<eq.ExamQuestion>());
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuestionDialog(context),
        backgroundColor: AppTheme.darkBlue,
        icon: const Icon(Icons.add),
        label: const Text('إضافة سؤال'),
      ),
      ),
    );
    
  }

  Widget _buildContent(
      BuildContext context, Exam exam, List<eq.ExamQuestion> questions) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExamInfo(exam, questions.length),
          const SizedBox(height: 16),
          _buildQuestionsSection(context, questions),
        ],
      ),
    );
  }

  Widget _buildExamInfo(Exam exam, int questionsCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exam.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: exam.status == ExamStatus.draft
                      ? AppTheme.yellow.withOpacity(0.2)
                      : AppTheme.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  exam.status == ExamStatus.draft ? 'مسودة' : 'منشور',
                  style: TextStyle(
                    color: exam.status == ExamStatus.draft
                        ? AppTheme.yellow
                        : AppTheme.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (exam.description != null) ...[
            const SizedBox(height: 12),
            Text(
              exam.description!,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkBlue.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _buildInfoItem(Icons.quiz, 'الأسئلة', '$questionsCount سؤال'),
              if (exam.durationMinutes != null)
                _buildInfoItem(
                    Icons.timer, 'المدة', '${exam.durationMinutes} دقيقة'),
              if (exam.passingScore != null)
                _buildInfoItem(
                    Icons.grade, 'درجة النجاح', '${exam.passingScore}%'),
              _buildInfoItem(
                Icons.replay,
                'الإعادة',
                exam.allowRetake ? 'مسموح (${exam.maxAttempts})' : 'غير مسموح',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppTheme.darkBlue),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.darkBlue.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionsSection(
      BuildContext context, List<eq.ExamQuestion> questions) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الأسئلة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkBlue,
            ),
          ),
          const SizedBox(height: 16),
          if (questions.isEmpty)
            _buildEmptyQuestions()
          else
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _QuestionCard(
                question: question,
                index: index + 1,
                onEdit: () => _showQuestionDialog(context, question: question),
                onDelete: () => _confirmDeleteQuestion(context, question),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyQuestions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.quiz_outlined,
                size: 64, color: AppTheme.darkBlue.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              'لا توجد أسئلة',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkBlue.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ابدأ بإضافة أسئلة للامتحان',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.darkBlue.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionDialog(BuildContext context, {eq.ExamQuestion? question}) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ExamBloc>(),
        child: QuestionFormDialog(
          examId: exam.id,
          question: question,
          nextOrderNumber: question == null
              ? (context.read<ExamBloc>().state is ExamDetailsLoaded
                  ? (context.read<ExamBloc>().state as ExamDetailsLoaded)
                          .questions
                          .length +
                      1
                  : 1)
              : question.orderNumber,
        ),
      ),
    );
  }

  void _confirmDeleteQuestion(BuildContext context, eq.ExamQuestion question) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا السؤال؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ExamBloc>().add(DeleteQuestion(question.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final eq.ExamQuestion question;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.darkBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...question.options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              final optionLetter =
                  String.fromCharCode(65 + optionIndex); // A, B, C, D
              final isCorrect = optionLetter == question.correctAnswer;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppTheme.green.withOpacity(0.1)
                      : AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect ? AppTheme.green : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? AppTheme.green
                            : AppTheme.darkBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          optionLetter,
                          style: TextStyle(
                            color:
                                isCorrect ? AppTheme.white : AppTheme.darkBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: AppTheme.darkBlue,
                          fontWeight:
                              isCorrect ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      const Icon(Icons.check_circle,
                          color: AppTheme.green, size: 20),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'النقاط: ${question.points}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.darkBlue.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('تعديل'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('حذف'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
