import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String studentId;
  final String courseId;
  final String providerId;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final String? transactionId;
  final PaymentStatus status;
  final DateTime? paymentDate;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.providerId,
    required this.amount,
    this.currency = 'SAR',
    required this.paymentMethod,
    this.transactionId,
    this.status = PaymentStatus.pending,
    this.paymentDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        courseId,
        providerId,
        amount,
        currency,
        paymentMethod,
        transactionId,
        status,
        paymentDate,
        createdAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'course_id': courseId,
      'provider_id': providerId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod.name,
      'transaction_id': transactionId,
      'status': status.name,
      'payment_date': paymentDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      courseId: json['course_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'SAR',
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == (json['payment_method'] ?? 'credit_card'),
        orElse: () => PaymentMethod.creditCard,
      ),
      transactionId: json['transaction_id'],
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum PaymentMethod { creditCard, applePay, googlePay, bankTransfer }

enum PaymentStatus { pending, completed, failed, refunded }
