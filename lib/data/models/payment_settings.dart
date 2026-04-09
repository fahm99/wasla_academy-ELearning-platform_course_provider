import 'package:equatable/equatable.dart';

class PaymentSettings extends Equatable {
  final String id;
  final String providerId;
  final String? walletNumber;
  final String? walletOwnerName;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountOwnerName;
  final String? iban;
  final String? additionalInfo;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentSettings({
    required this.id,
    required this.providerId,
    this.walletNumber,
    this.walletOwnerName,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountOwnerName,
    this.iban,
    this.additionalInfo,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        providerId,
        walletNumber,
        walletOwnerName,
        bankName,
        bankAccountNumber,
        bankAccountOwnerName,
        iban,
        additionalInfo,
        isActive,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'wallet_number': walletNumber,
      'wallet_owner_name': walletOwnerName,
      'bank_name': bankName,
      'bank_account_number': bankAccountNumber,
      'bank_account_owner_name': bankAccountOwnerName,
      'iban': iban,
      'additional_info': additionalInfo,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PaymentSettings.fromJson(Map<String, dynamic> json) {
    return PaymentSettings(
      id: json['id'] ?? '',
      providerId: json['provider_id'] ?? '',
      walletNumber: json['wallet_number'],
      walletOwnerName: json['wallet_owner_name'],
      bankName: json['bank_name'],
      bankAccountNumber: json['bank_account_number'],
      bankAccountOwnerName: json['bank_account_owner_name'],
      iban: json['iban'],
      additionalInfo: json['additional_info'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  PaymentSettings copyWith({
    String? id,
    String? providerId,
    String? walletNumber,
    String? walletOwnerName,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountOwnerName,
    String? iban,
    String? additionalInfo,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentSettings(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      walletNumber: walletNumber ?? this.walletNumber,
      walletOwnerName: walletOwnerName ?? this.walletOwnerName,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankAccountOwnerName: bankAccountOwnerName ?? this.bankAccountOwnerName,
      iban: iban ?? this.iban,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
