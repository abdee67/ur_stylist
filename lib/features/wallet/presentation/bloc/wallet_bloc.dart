import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ur_stylist/features/wallet/domain/entities/payout_account_entity.dart';
import 'package:ur_stylist/features/wallet/domain/entities/transaction_entity.dart';
import 'package:ur_stylist/features/wallet/domain/entities/wallet_entity.dart';
import 'package:ur_stylist/features/wallet/domain/usecases/wallet_usecases.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final LoadWalletDashboard loadWalletDashboard;
  final SubmitDepositProof submitDepositProof;
  final RequestWithdrawal requestWithdrawal;

  WalletBloc(
    this.loadWalletDashboard,
    this.submitDepositProof,
    this.requestWithdrawal,
  ) : super(WalletState.initial()) {
    on<WalletStarted>(_onStarted);
    on<WalletRefreshed>(_onStarted);
    on<WalletFilterChanged>((event, emit) {
      emit(state.copyWith(filter: event.filter, clearMessages: true));
    });
    on<DepositProofSubmitted>(_onDepositProofSubmitted);
    on<WithdrawalRequested>(_onWithdrawalRequested);
  }

  Future<void> _onStarted(WalletEvent event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final result = await loadWalletDashboard();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (data) => emit(
        state.copyWith(
          isLoading: false,
          wallet: data.wallet,
          transactions: data.transactions,
          payoutAccount: data.payoutAccount,
        ),
      ),
    );
  }

  Future<void> _onDepositProofSubmitted(
    DepositProofSubmitted event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearMessages: true));
    final result = await submitDepositProof(
      amount: event.amount,
      proof: event.proof,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isActionLoading: false, errorMessage: failure.message),
      ),
      (_) {
        emit(
          state.copyWith(
            isActionLoading: false,
            successMessage:
                "Your deposit is under review. We'll notify you within 24 hours.",
          ),
        );
        add(const WalletRefreshed());
      },
    );
  }

  Future<void> _onWithdrawalRequested(
    WithdrawalRequested event,
    Emitter<WalletState> emit,
  ) async {
    final wallet = state.wallet;
    final payout = state.payoutAccount;
    if (wallet == null || payout == null) {
      emit(state.copyWith(errorMessage: 'Add a payout account first.'));
      return;
    }
    if (wallet.requiresDeposit) {
      emit(
        state.copyWith(
          errorMessage: 'Your security deposit must be verified first.',
        ),
      );
      return;
    }
    if (event.amount < 200) {
      emit(state.copyWith(errorMessage: 'Minimum withdrawal is ETB 200.'));
      return;
    }
    if (event.amount > wallet.withdrawable) {
      emit(
        state.copyWith(
          errorMessage:
              'You can withdraw at most ETB ${wallet.withdrawable.toStringAsFixed(2)}.',
        ),
      );
      return;
    }

    emit(state.copyWith(isActionLoading: true, clearMessages: true));
    final result = await requestWithdrawal(
      amount: event.amount,
      payoutAccountId: payout.id,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isActionLoading: false, errorMessage: failure.message),
      ),
      (_) {
        emit(
          state.copyWith(
            isActionLoading: false,
            successMessage: 'Withdrawal request submitted.',
          ),
        );
        add(const WalletRefreshed());
      },
    );
  }
}
