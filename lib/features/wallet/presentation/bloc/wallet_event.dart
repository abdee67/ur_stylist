part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class WalletStarted extends WalletEvent {
  const WalletStarted();
}

class WalletRefreshed extends WalletEvent {
  const WalletRefreshed();
}

class WalletFilterChanged extends WalletEvent {
  final String filter;
  const WalletFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class DepositProofSubmitted extends WalletEvent {
  final double amount;
  final File proof;
  const DepositProofSubmitted({required this.amount, required this.proof});
  @override
  List<Object?> get props => [amount, proof.path];
}

class WithdrawalRequested extends WalletEvent {
  final double amount;
  const WithdrawalRequested(this.amount);
  @override
  List<Object?> get props => [amount];
}
