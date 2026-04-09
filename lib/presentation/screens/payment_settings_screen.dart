import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/data/models/payment_settings.dart';
import 'package:course_provider/data/repositories/main_repository.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _walletNumberController;
  late TextEditingController _walletOwnerController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccountController;
  late TextEditingController _bankOwnerController;
  late TextEditingController _ibanController;
  late TextEditingController _additionalInfoController;

  bool _isLoading = true;
  bool _isSaving = false;
  PaymentSettings? _currentSettings;

  @override
  void initState() {
    super.initState();
    _walletNumberController = TextEditingController();
    _walletOwnerController = TextEditingController();
    _bankNameController = TextEditingController();
    _bankAccountController = TextEditingController();
    _bankOwnerController = TextEditingController();
    _ibanController = TextEditingController();
    _additionalInfoController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _walletNumberController.dispose();
    _walletOwnerController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _bankOwnerController.dispose();
    _ibanController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final repository = context.read<MainRepository>();
      final settings = await repository.getPaymentSettings();

      if (settings != null) {
        setState(() {
          _currentSettings = settings;
          _walletNumberController.text = settings.walletNumber ?? '';
          _walletOwnerController.text = settings.walletOwnerName ?? '';
          _bankNameController.text = settings.bankName ?? '';
          _bankAccountController.text = settings.bankAccountNumber ?? '';
          _bankOwnerController.text = settings.bankAccountOwnerName ?? '';
          _ibanController.text = settings.iban ?? '';
          _additionalInfoController.text = settings.additionalInfo ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الإعدادات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = context.read<MainRepository>();
      final user = await repository.getUser();

      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      final settings = PaymentSettings(
        id: _currentSettings?.id ?? '',
        providerId: user.id,
        walletNumber: _walletNumberController.text.isEmpty
            ? null
            : _walletNumberController.text,
        walletOwnerName: _walletOwnerController.text.isEmpty
            ? null
            : _walletOwnerController.text,
        bankName:
            _bankNameController.text.isEmpty ? null : _bankNameController.text,
        bankAccountNumber: _bankAccountController.text.isEmpty
            ? null
            : _bankAccountController.text,
        bankAccountOwnerName: _bankOwnerController.text.isEmpty
            ? null
            : _bankOwnerController.text,
        iban: _ibanController.text.isEmpty ? null : _ibanController.text,
        additionalInfo: _additionalInfoController.text.isEmpty
            ? null
            : _additionalInfoController.text,
        isActive: true,
        createdAt: _currentSettings?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await repository.savePaymentSettings(settings);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ إعدادات الدفع بنجاح'),
            backgroundColor: AppTheme.green,
          ),
        );
        await _loadSettings();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في حفظ الإعدادات'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBlue,
        foregroundColor: AppTheme.white,
        title: const Text('إعدادات الدفع'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 20),
                    _buildWalletSection(),
                    const SizedBox(height: 20),
                    _buildBankSection(),
                    const SizedBox(height: 20),
                    _buildAdditionalInfoSection(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.blue),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, color: AppTheme.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'هذه البيانات ستظهر للطلاب عند الدفع. تأكد من صحة المعلومات.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.darkBlue,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'المحفظة الإلكترونية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _walletNumberController,
              decoration: const InputDecoration(
                labelText: 'رقم المحفظة',
                hintText: '05xxxxxxxx',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _walletOwnerController,
              decoration: const InputDecoration(
                labelText: 'اسم صاحب المحفظة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: AppTheme.green,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'الحساب البنكي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bankNameController,
              decoration: const InputDecoration(
                labelText: 'اسم البنك',
                hintText: 'مثال: البنك الأهلي',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bankAccountController,
              decoration: const InputDecoration(
                labelText: 'رقم الحساب',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bankOwnerController,
              decoration: const InputDecoration(
                labelText: 'اسم صاحب الحساب',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ibanController,
              decoration: const InputDecoration(
                labelText: 'IBAN (اختياري)',
                hintText: 'SA...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notes,
                    color: AppTheme.yellow,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'معلومات إضافية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _additionalInfoController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات للطلاب (اختياري)',
                hintText: 'مثال: يرجى إرفاق صورة واضحة للإيصال',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveSettings,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppTheme.white),
                ),
              )
            : const Icon(Icons.save),
        label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ الإعدادات'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.darkBlue,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
