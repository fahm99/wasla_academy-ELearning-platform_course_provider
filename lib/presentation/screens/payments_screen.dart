import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:course_provider/core/theme/app_theme.dart';
import 'package:course_provider/core/utils/app_icons.dart';
import 'package:course_provider/data/models/payment.dart';
import 'package:course_provider/data/repositories/main_repository.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<Payment> _payments = [];
  bool _isLoading = true;
  String _selectedFilter = 'الكل';
  double _totalEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);

    try {
      final repository = context.read<MainRepository>();
      final user = await repository.getUser();

      if (user != null) {
        final payments = await repository.getProviderPayments(user.id);
        final total = await repository.getTotalEarnings();

        setState(() {
          _payments = payments;
          _totalEarnings = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل المدفوعات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Payment> get _filteredPayments {
    if (_selectedFilter == 'الكل') {
      return _payments;
    } else if (_selectedFilter == 'مكتمل') {
      return _payments
          .where((p) => p.status == PaymentStatus.completed)
          .toList();
    } else if (_selectedFilter == 'معلق') {
      return _payments.where((p) => p.status == PaymentStatus.pending).toList();
    } else if (_selectedFilter == 'فاشل') {
      return _payments.where((p) => p.status == PaymentStatus.failed).toList();
    }
    return _payments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: RefreshIndicator(
        onRefresh: _loadPayments,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEarningsCard(),
                    const SizedBox(height: 16),
                    _buildFilterButtons(),
                    const SizedBox(height: 16),
                    _buildPaymentsList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.darkBlue, AppTheme.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  AppIcons.wallet,
                  color: AppTheme.yellow,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'إجمالي الأرباح',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${_totalEarnings.toStringAsFixed(2)} ريال',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'من ${_payments.where((p) => p.status == PaymentStatus.completed).length} عملية مكتملة',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('الكل', _payments.length),
          const SizedBox(width: 8),
          _buildFilterChip(
            'مكتمل',
            _payments.where((p) => p.status == PaymentStatus.completed).length,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'معلق',
            _payments.where((p) => p.status == PaymentStatus.pending).length,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'فاشل',
            _payments.where((p) => p.status == PaymentStatus.failed).length,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: AppTheme.white,
      selectedColor: AppTheme.darkBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.white : AppTheme.darkBlue,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildPaymentsList() {
    final filtered = _filteredPayments;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.payment,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد مدفوعات',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'سجل المدفوعات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _buildPaymentCard(filtered[index]);
          },
        ),
      ],
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'دفعة #${payment.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'كورس: ${payment.courseId}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${payment.amount.toStringAsFixed(2)} ريال',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusChip(payment.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(
                  Icons.calendar_today,
                  'التاريخ',
                  payment.paymentDate != null
                      ? DateFormat('yyyy-MM-dd').format(payment.paymentDate!)
                      : 'غير محدد',
                ),
                _buildInfoRow(
                  Icons.payment,
                  'الطريقة',
                  _getPaymentMethodLabel(payment.paymentMethod),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(PaymentStatus status) {
    Color color;
    String label;

    switch (status) {
      case PaymentStatus.completed:
        color = AppTheme.green;
        label = 'مكتمل';
        break;
      case PaymentStatus.pending:
        color = AppTheme.yellow;
        label = 'معلق';
        break;
      case PaymentStatus.failed:
        color = AppTheme.red;
        label = 'فاشل';
        break;
      case PaymentStatus.refunded:
        color = AppTheme.darkGray;
        label = 'مسترد';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'بطاقة ائتمان';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.darkGray),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.darkBlue,
          ),
        ),
      ],
    );
  }
}
