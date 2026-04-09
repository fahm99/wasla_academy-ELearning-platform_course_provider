import 'package:flutter/material.dart';
import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/data/models/certificate/signature_data.dart';

class SignatureDialog extends StatefulWidget {
  final SignatureData? signature;
  final Function(SignatureData) onSave;

  const SignatureDialog({
    super.key,
    this.signature,
    required this.onSave,
  });

  @override
  State<SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.signature?.name ?? '');
    _titleController =
        TextEditingController(text: widget.signature?.title ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.signature == null ? 'إضافة توقيع' : 'تحرير التوقيع'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'اسم الموقع',
              hintText: 'مثال: د. أحمد محمد',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'المنصب',
              hintText: 'مثال: عميد الكلية',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _titleController.text.isNotEmpty) {
              widget.onSave(SignatureData(
                name: _nameController.text,
                title: _titleController.text,
              ));
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkBlue,
            foregroundColor: AppTheme.white,
          ),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
