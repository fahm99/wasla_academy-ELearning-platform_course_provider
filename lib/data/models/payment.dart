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
  final String? transactionReference;
  final String? receiptImageUrl;
  final String? studentName;
  final String? courseName;
  final PaymentStatus status;
  final DateTime? paymentDate;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? rejectionReason;
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
    this.transactionReference,
    this.receiptImageUrl,
    this.studentName,
    this.courseName,
    this.status = PaymentStatus.pending,
    this.paymentDate,
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
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
        transactionReference,
        receiptImageUrl,
        studentName,
        courseName,
        status,
        paymentDate,
        verifiedBy,
        verifiedAt,
        rejectionReason,
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
      'transaction_reference': transactionReference,
      'receipt_image_url': receiptImageUrl,
      'student_name': studentName,
      'course_name': courseName,
      'status': status.name,
      'payment_date': paymentDate?.toIso8601String(),
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
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
        (e) => e.name == (json['payment_method'] ?? 'wallet'),
        orElse: () => PaymentMethod.wallet,
      ),
      transactionId: json['transaction_id'],
      transactionReference: json['transaction_reference'],
      receiptImageUrl: json['receipt_image_url'],
      studentName: json['student_name'],
      courseName: json['course_name'],
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      verifiedBy: json['verified_by'],
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum PaymentMethod { wallet, bankTransfer }

enum PaymentStatus { pending, completed, failed, refunded }
