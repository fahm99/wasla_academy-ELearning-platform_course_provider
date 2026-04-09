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
    } else if (_selectedFilter == 'معلق') {
      return _payments.where((p) => p.status == PaymentStatus.pending).toList();
    } else if (_selectedFilter == 'مكتمل') {
      return _payments
          .where((p) => p.status == PaymentStatus.completed)
          .toList();
    } else if (_selectedFilter == 'مرفوض') {
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
    final pendingCount =
        _payments.where((p) => p.status == PaymentStatus.pending).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1445),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C1445).withOpacity(0.3),
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
          Row(
            children: [
              Text(
                'من ${_payments.where((p) => p.status == PaymentStatus.completed).length} عملية مكتملة',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.white.withOpacity(0.8),
                ),
              ),
              if (pendingCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pendingCount بانتظار المراجعة',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
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
            'معلق',
            _payments.where((p) => p.status == PaymentStatus.pending).length,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'مكتمل',
            _payments.where((p) => p.status == PaymentStatus.completed).length,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'مرفوض',
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Icon(
              Icons.payment,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            SizedBox(height: 16),
            Text(
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 16, color: AppTheme.darkGray),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              payment.studentName ?? 'طالب غير معروف',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.book,
                              size: 16, color: AppTheme.darkGray),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              payment.courseName ?? 'كورس غير معروف',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.darkGray,
                              ),
                            ),
                          ),
                        ],
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
            _buildPaymentDetails(payment),
            if (payment.receiptImageUrl != null) ...[
              const SizedBox(height: 12),
              _buildReceiptImage(payment.receiptImageUrl!),
            ],
            if (payment.status == PaymentStatus.pending) ...[
              const SizedBox(height: 12),
              _buildActionButtons(payment),
            ],
            if (payment.status == PaymentStatus.failed &&
                payment.rejectionReason != null) ...[
              const SizedBox(height: 12),
              _buildRejectionReason(payment.rejectionReason!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(Payment payment) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildInfoChip(
          Icons.payment,
          'الطريقة',
          _getPaymentMethodLabel(payment.paymentMethod),
        ),
        if (payment.transactionReference != null)
          _buildInfoChip(
            Icons.receipt,
            'رقم العملية',
            payment.transactionReference!,
          ),
        _buildInfoChip(
          Icons.calendar_today,
          'التاريخ',
          DateFormat('yyyy-MM-dd HH:mm').format(payment.createdAt),
        ),
      ],
    );
  }

  Widget _buildReceiptImage(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.image, size: 16, color: AppTheme.darkGray),
                SizedBox(width: 8),
                Text(
                  'صورة الإيصال',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showReceiptImage(imageUrl),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: AppTheme.lightGray,
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Payment payment) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _approvePayment(payment),
            icon: const Icon(Icons.check_circle),
            label: const Text('تأكيد الدفع'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.green,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _rejectPayment(payment),
            icon: const Icon(Icons.cancel),
            label: const Text('رفض الدفع'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectionReason(String reason) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: AppTheme.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'سبب الرفض: $reason',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(PaymentStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case PaymentStatus.completed:
        color = AppTheme.green;
        label = 'مكتمل';
        icon = Icons.check_circle;
        break;
      case PaymentStatus.pending:
        color = AppTheme.yellow;
        label = 'معلق';
        icon = Icons.pending;
        break;
      case PaymentStatus.failed:
        color = AppTheme.red;
        label = 'مرفوض';
        icon = Icons.cancel;
        break;
      case PaymentStatus.refunded:
        color = AppTheme.darkGray;
        label = 'مسترد';
        icon = Icons.replay;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.darkGray),
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

  String _getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return 'محفظة إلكترونية';
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
    }
  }

  void _showReceiptImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('صورة الإيصال'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.network(imageUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approvePayment(Payment payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الدفع'),
        content: Text(
          'هل أنت متأكد من تأكيد دفع ${payment.studentName} للكورس ${payment.courseName}؟\n\nسيتم تفعيل وصول الطالب للكورس فوراً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repository = context.read<MainRepository>();
        final success = await repository.approvePayment(payment.id);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تأكيد الدفع بنجاح'),
              backgroundColor: AppTheme.green,
            ),
          );
          await _loadPayments();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ في تأكيد الدفع'),
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
      }
    }
  }

  Future<void> _rejectPayment(Payment payment) async {
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الدفع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من رفض دفع ${payment.studentName}؟',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض *',
                border: OutlineInputBorder(),
                hintText: 'مثال: الإيصال غير واضح',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirm == true && reasonController.text.isNotEmpty) {
      try {
        final repository = context.read<MainRepository>();
        final success = await repository.rejectPayment(
          payment.id,
          reasonController.text,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفض الدفع'),
              backgroundColor: AppTheme.red,
            ),
          );
          await _loadPayments();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ في رفض الدفع'),
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
      }
    }

    reasonController.dispose();
  }
}
