import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String walletId;
  final String transactionType;
  final double amount;
  final String source;
  final String? reference;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.walletId,
    required this.transactionType,
    required this.amount,
    required this.source,
    this.reference,
    required this.metadata,
    required this.createdAt,
  });

  bool get isCredit => transactionType == 'credit';
  bool get isPending =>
      metadata['status']?.toString().contains('pending') == true;

  @override
  List<Object?> get props => [
    id,
    walletId,
    transactionType,
    amount,
    source,
    reference,
    metadata,
    createdAt,
  ];
}
