part of 'wallet_bloc.dart';

class WalletState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final WalletEntity? wallet;
  final List<TransactionEntity> transactions;
  final PayoutAccountEntity? payoutAccount;
  final String filter;
  final String? errorMessage;
  final String? successMessage;

  const WalletState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.wallet,
    this.transactions = const [],
    this.payoutAccount,
    this.filter = 'all',
    this.errorMessage,
    this.successMessage,
  });

  factory WalletState.initial() => const WalletState();

  WalletState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    WalletEntity? wallet,
    List<TransactionEntity>? transactions,
    PayoutAccountEntity? payoutAccount,
    String? filter,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      payoutAccount: payoutAccount ?? this.payoutAccount,
      filter: filter ?? this.filter,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  List<TransactionEntity> get filteredTransactions {
    return transactions.where((tx) {
      if (filter == 'earnings') return tx.source == 'booking_earning';
      if (filter == 'deposits') return tx.source == 'topup';
      if (filter == 'withdrawals') return tx.source == 'withdrawal';
      return true;
    }).toList();
  }

  @override
  List<Object?> get props => [
    isLoading,
    isActionLoading,
    wallet,
    transactions,
    payoutAccount,
    filter,
    errorMessage,
    successMessage,
  ];
}
