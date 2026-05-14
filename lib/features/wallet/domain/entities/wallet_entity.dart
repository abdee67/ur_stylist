import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String id;
  final String stylistId;
  final double balance;
  final String currency;
  final double securityDeposit;
  final double minimumDeposit;
  final bool depositVerified;
  final bool isActive;

  const WalletEntity({
    required this.id,
    required this.stylistId,
    required this.balance,
    required this.currency,
    required this.securityDeposit,
    required this.minimumDeposit,
    required this.depositVerified,
    required this.isActive,
  });

  bool get requiresDeposit {
    return !depositVerified || securityDeposit < minimumDeposit;
  }

  double get withdrawable {
    final amount = balance - minimumDeposit;
    return amount < 0 ? 0 : amount;
  }

  double get totalBalance => balance + securityDeposit;

  @override
  List<Object?> get props => [
    id,
    stylistId,
    balance,
    currency,
    securityDeposit,
    minimumDeposit,
    depositVerified,
    isActive,
  ];
}
