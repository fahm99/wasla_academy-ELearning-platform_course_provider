import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exam.dart';
import '../blocs/exam/exam_bloc.dart';
import '../blocs/exam/exam_event.dart';

class ExamFormDialog extends StatefulWidget {
  final String courseId;
  final Exam? exam;

  const ExamFormDialog({
    super.key,
    required this.courseId,
    this.exam,
  });

  @override
  State<ExamFormDialog> createState() => _ExamFormDialogState();
}

class _ExamFormDialogState extends State<ExamFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _totalQuestionsController;
  late TextEditingController _passingScoreController;
  late TextEditingController _durationController;
  late TextEditingController _maxAttemptsController;
  late bool _allowRetake;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.exam?.title);
    _descriptionController =
        TextEditingController(text: widget.exam?.description);
    _totalQuestionsController = TextEditingController(
      text: widget.exam?.totalQuestions?.toString(),
    );
    _passingScoreController = TextEditingController(
      text: widget.exam?.passingScore?.toString() ?? '60',
    );
    _durationController = TextEditingController(
      text: widget.exam?.durationMinutes?.toString() ?? '30',
    );
    _maxAttemptsController = TextEditingController(
      text: widget.exam?.maxAttempts.toString() ?? '3',
    );
    _allowRetake = widget.exam?.allowRetake ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalQuestionsController.dispose();
    _passingScoreController.dispose();
    _durationController.dispose();
    _maxAttemptsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.exam != null;

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isEdit),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'عنوان الامتحان',
                        hint: 'مثال: امتحان الوحدة الأولى',
                        icon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال عنوان الامتحان';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'الوصف (اختياري)',
                        hint: 'وصف مختصر للامتحان',
                        icon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _totalQuestionsController,
                              label: 'عدد الأسئلة',
                              hint: '10',
                              icon: Icons.quiz,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _passingScoreController,
                              label: 'درجة النجاح (%)',
                              hint: '60',
                              icon: Icons.grade,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final score = int.tryParse(value);
                                  if (score == null ||
                                      score < 0 ||
                                      score > 100) {
                                    return 'أدخل قيمة بين 0 و 100';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _durationController,
                        label: 'المدة (بالدقائق)',
                        hint: '30',
                        icon: Icons.timer,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('السماح بإعادة الامتحان'),
                        value: _allowRetake,
                        onChanged: (value) {
                          setState(() {
                            _allowRetake = value;
                          });
                        },
                        activeColor: AppTheme.darkBlue,
                      ),
                      if (_allowRetake) ...[
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _maxAttemptsController,
                          label: 'عدد المحاولات المسموحة',
                          hint: '3',
                          icon: Icons.replay,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final attempts = int.tryParse(value);
                              if (attempts == null || attempts < 1) {
                                return 'أدخل قيمة أكبر من 0';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _buildActions(isEdit),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEdit) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.darkBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.quiz, color: AppTheme.white, size: 28),
          const SizedBox(width: 12),
          Text(
            isEdit ? 'تعديل الامتحان' : 'إضافة امتحان جديد',
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.darkBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.darkBlue, width: 2),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildActions(bool isEdit) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        border: Border(
          top: BorderSide(color: AppTheme.darkBlue.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkBlue,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(isEdit ? 'تحديث' : 'إضافة'),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final totalQuestions = _totalQuestionsController.text.isNotEmpty
        ? int.tryParse(_totalQuestionsController.text)
        : null;
    final passingScore = _passingScoreController.text.isNotEmpty
        ? int.tryParse(_passingScoreController.text)
        : null;
    final duration = _durationController.text.isNotEmpty
        ? int.tryParse(_durationController.text)
        : null;
    final maxAttempts = _maxAttemptsController.text.isNotEmpty
        ? int.tryParse(_maxAttemptsController.text) ?? 3
        : 3;

    if (widget.exam == null) {
      context.read<ExamBloc>().add(
            CreateExam(
              courseId: widget.courseId,
              title: _titleController.text,
              description: _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : null,
              totalQuestions: totalQuestions,
              passingScore: passingScore,
              durationMinutes: duration,
              allowRetake: _allowRetake,
              maxAttempts: maxAttempts,
            ),
          );
    } else {
      context.read<ExamBloc>().add(
            UpdateExam(
              examId: widget.exam!.id,
              title: _titleController.text,
              description: _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : null,
              totalQuestions: totalQuestions,
              passingScore: passingScore,
              durationMinutes: duration,
              allowRetake: _allowRetake,
              maxAttempts: maxAttempts,
            ),
          );
    }

    Navigator.pop(context);
  }
}
