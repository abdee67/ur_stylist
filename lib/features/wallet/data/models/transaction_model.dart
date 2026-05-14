import 'package:ur_stylist/features/wallet/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.walletId,
    required super.transactionType,
    required super.amount,
    required super.source,
    super.reference,
    required super.metadata,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] ?? '').toString(),
      walletId: (json['wallet_id'] ?? '').toString(),
      transactionType: (json['transaction_type'] ?? '').toString(),
      amount: double.tryParse((json['amount'] ?? '0').toString()) ?? 0,
      source: (json['source'] ?? '').toString(),
      reference: json['reference']?.toString(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'])
          : const {},
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString())?.toLocal() ??
          DateTime.now(),
    );
  }
}
