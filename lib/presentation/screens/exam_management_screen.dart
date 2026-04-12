import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exam.dart';
import '../../data/models/course.dart';
import '../blocs/exam/exam_bloc.dart';
import '../blocs/exam/exam_event.dart';
import '../blocs/exam/exam_state.dart';
import 'exam_details_screen.dart';
import '../widgets/exam_form_dialog.dart';

class ExamManagementScreen extends StatelessWidget {
  final Course course;

  const ExamManagementScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExamBloc()..add(LoadCourseExams(course.id)),
      child: _ExamManagementView(course: course),
    );
  }
}

class _ExamManagementView extends StatelessWidget {
  final Course course;

  const _ExamManagementView({required this.course});

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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إدارة الامتحانات', style: TextStyle(fontSize: 18)),
              Text(
                course.title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
            ],
          ),
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
            context.read<ExamBloc>().add(LoadCourseExams(course.id));
          }
        },
        builder: (context, state) {
          if (state is ExamLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExamsLoaded) {
            if (state.exams.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildExamsList(context, state.exams);
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExamDialog(context),
        backgroundColor: AppTheme.darkBlue,
        icon: const Icon(Icons.add),
        label: const Text('إضافة امتحان'),
      ),
      ),
    );
    
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined,
              size: 100, color: AppTheme.darkBlue.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'لا توجد امتحانات',
            style: TextStyle(
                fontSize: 20, color: AppTheme.darkBlue.withOpacity(0.6)),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة امتحان جديد',
            style: TextStyle(color: AppTheme.darkBlue.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildExamsList(BuildContext context, List<Exam> exams) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return _ExamCard(
          exam: exam,
          onTap: () => _navigateToExamDetails(context, exam),
          onEdit: () => _showExamDialog(context, exam: exam),
          onDelete: () => _confirmDelete(context, exam),
          onPublish: () => _publishExam(context, exam),
        );
      },
    );
  }

  void _showExamDialog(BuildContext context, {Exam? exam}) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ExamBloc>(),
        child: ExamFormDialog(courseId: course.id, exam: exam),
      ),
    );
  }

  void _navigateToExamDetails(BuildContext context, Exam exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamDetailsScreen(exam: exam),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Exam exam) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الامتحان "${exam.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ExamBloc>().add(DeleteExam(exam.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _publishExam(BuildContext context, Exam exam) {
    context.read<ExamBloc>().add(PublishExam(exam.id));
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPublish;

  const _ExamCard({
    required this.exam,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    final isDraft = exam.status == ExamStatus.draft;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        if (exam.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            exam.description!,
                            style: TextStyle(
                                color: AppTheme.darkBlue.withOpacity(0.6)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDraft
                          ? AppTheme.yellow.withOpacity(0.2)
                          : AppTheme.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isDraft ? 'مسودة' : 'منشور',
                      style: TextStyle(
                        color: isDraft ? AppTheme.yellow : AppTheme.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (exam.totalQuestions != null)
                    _buildInfoChip(Icons.quiz, '${exam.totalQuestions} سؤال'),
                  if (exam.durationMinutes != null)
                    _buildInfoChip(
                        Icons.timer, '${exam.durationMinutes} دقيقة'),
                  if (exam.passingScore != null)
                    _buildInfoChip(
                        Icons.grade, 'النجاح: ${exam.passingScore}%'),
                  _buildInfoChip(
                    Icons.replay,
                    exam.allowRetake
                        ? 'يسمح بالإعادة (${exam.maxAttempts})'
                        : 'لا يسمح بالإعادة',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (isDraft)
                    TextButton.icon(
                      onPressed: onPublish,
                      icon: const Icon(Icons.publish, size: 18),
                      label: const Text('نشر'),
                      style:
                          TextButton.styleFrom(foregroundColor: AppTheme.green),
                    ),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('تعديل'),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('حذف'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.darkBlue.withOpacity(0.6)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 13, color: AppTheme.darkBlue.withOpacity(0.6)),
        ),
      ],
    );
  }
}
