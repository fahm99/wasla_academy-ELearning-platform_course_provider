import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exam_question.dart';
import '../blocs/exam/exam_bloc.dart';
import '../blocs/exam/exam_event.dart';

class QuestionFormDialog extends StatefulWidget {
  final String examId;
  final ExamQuestion? question;
  final int nextOrderNumber;

  const QuestionFormDialog({
    super.key,
    required this.examId,
    this.question,
    required this.nextOrderNumber,
  });

  @override
  State<QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends State<QuestionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late TextEditingController _pointsController;
  String _correctAnswer = 'A';

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: widget.question?.questionText);
    _pointsController = TextEditingController(
      text: widget.question?.points.toString() ?? '1',
    );

    // Initialize 4 option controllers
    _optionControllers = List.generate(4, (index) {
      final options = widget.question?.options ?? [];
      return TextEditingController(
        text: index < options.length ? options[index] : '',
      );
    });

    if (widget.question != null) {
      _correctAnswer = widget.question!.correctAnswer;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _pointsController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.question != null;

    return Dialog(
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 800),
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
                      _buildQuestionField(),
                      const SizedBox(height: 24),
                      const Text(
                        'الخيارات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildOptionFields(),
                      const SizedBox(height: 24),
                      _buildPointsField(),
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
            isEdit ? 'تعديل السؤال' : 'إضافة سؤال جديد',
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

  Widget _buildQuestionField() {
    return TextFormField(
      controller: _questionController,
      decoration: InputDecoration(
        labelText: 'نص السؤال',
        hintText: 'اكتب السؤال هنا...',
        prefixIcon: const Icon(Icons.help_outline, color: AppTheme.darkBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.darkBlue, width: 2),
        ),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال نص السؤال';
        }
        return null;
      },
    );
  }

  List<Widget> _buildOptionFields() {
    final options = ['A', 'B', 'C', 'D'];
    return List.generate(4, (index) {
      final optionLetter = options[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Radio<String>(
              value: optionLetter,
              groupValue: _correctAnswer,
              onChanged: (value) {
                setState(() {
                  _correctAnswer = value!;
                });
              },
              activeColor: AppTheme.green,
            ),
            Expanded(
              child: TextFormField(
                controller: _optionControllers[index],
                decoration: InputDecoration(
                  labelText: 'الخيار $optionLetter',
                  hintText: 'اكتب الخيار...',
                  prefixIcon: Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _correctAnswer == optionLetter
                            ? AppTheme.green
                            : AppTheme.darkBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          optionLetter,
                          style: TextStyle(
                            color: _correctAnswer == optionLetter
                                ? AppTheme.white
                                : AppTheme.darkBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _correctAnswer == optionLetter
                          ? AppTheme.green
                          : AppTheme.darkBlue,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الخيار $optionLetter';
                  }
                  return null;
                },
              ),
            ),
            if (_correctAnswer == optionLetter)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.check_circle, color: AppTheme.green),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPointsField() {
    return SizedBox(
      width: 150,
      child: TextFormField(
        controller: _pointsController,
        decoration: InputDecoration(
          labelText: 'النقاط',
          hintText: '1',
          prefixIcon: const Icon(Icons.grade, color: AppTheme.darkBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.darkBlue, width: 2),
          ),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال النقاط';
          }
          final points = int.tryParse(value);
          if (points == null || points < 1) {
            return 'أدخل قيمة أكبر من 0';
          }
          return null;
        },
      ),
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

    final options = _optionControllers.map((c) => c.text).toList();
    final points = int.parse(_pointsController.text);

    if (widget.question == null) {
      context.read<ExamBloc>().add(
            AddQuestion(
              examId: widget.examId,
              questionText: _questionController.text,
              options: options,
              correctAnswer: _correctAnswer,
              points: points,
              orderNumber: widget.nextOrderNumber,
            ),
          );
    } else {
      context.read<ExamBloc>().add(
            UpdateQuestion(
              questionId: widget.question!.id,
              questionText: _questionController.text,
              options: options,
              correctAnswer: _correctAnswer,
              points: points,
            ),
          );
    }

    Navigator.pop(context);
  }
}
