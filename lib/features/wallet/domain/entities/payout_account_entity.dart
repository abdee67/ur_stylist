import 'package:equatable/equatable.dart';

class PayoutAccountEntity extends Equatable {
  final String id;
  final String stylistId;
  final String accountHolderName;
  final String bankName;
  final String accountNumber;

  const PayoutAccountEntity({
    required this.id,
    required this.stylistId,
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
  });

  String get maskedAccount {
    if (accountNumber.length <= 4) return accountNumber;
    return '**** ${accountNumber.substring(accountNumber.length - 4)}';
  }

  @override
  List<Object?> get props => [
    id,
    stylistId,
    accountHolderName,
    bankName,
    accountNumber,
  ];
}
