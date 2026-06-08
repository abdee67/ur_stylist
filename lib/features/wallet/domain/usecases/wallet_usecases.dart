import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/wallet/domain/entities/payout_account_entity.dart';
import 'package:ur_stylist/features/wallet/domain/entities/transaction_entity.dart';
import 'package:ur_stylist/features/wallet/domain/entities/wallet_entity.dart';
import 'package:ur_stylist/features/wallet/domain/repositories/wallet_repository.dart';

class WalletDashboardData {
  final WalletEntity wallet;
  final List<TransactionEntity> transactions;
  final PayoutAccountEntity? payoutAccount;

  const WalletDashboardData({
    required this.wallet,
    required this.transactions,
    required this.payoutAccount,
  });
}

class LoadWalletDashboard {
  final WalletRepository repository;
  LoadWalletDashboard(this.repository);

  Future<Either<Failures, WalletDashboardData>> call() async {
    final wallet = await repository.getWallet();
    if (wallet.isLeft()) {
      return Left(
        wallet.swap().getOrElse(
          () => Failures(message: 'Something went wrong.'),
        ),
      );
    }
    final txs = await repository.getTransactions();
    if (txs.isLeft()) {
      return Left(
        txs.swap().getOrElse(() => Failures(message: 'Something went wrong.')),
      );
    }
    final payout = await repository.getPayoutAccount();
    if (payout.isLeft()) {
      return Left(
        payout.swap().getOrElse(
          () => Failures(message: 'Something went wrong.'),
        ),
      );
    }
    return Right(
      WalletDashboardData(
        wallet: wallet.getOrElse(() => throw StateError('wallet')),
        transactions: txs.getOrElse(() => const []),
        payoutAccount: payout.getOrElse(() => null),
      ),
    );
  }
}

class SubmitDepositProof {
  final WalletRepository repository;
  SubmitDepositProof(this.repository);
  Future<Either<Failures, void>> call({
    required double amount,
    required File proof,
  }) {
    return repository.submitDepositProof(amount: amount, proof: proof);
  }
}

class RequestWithdrawal {
  final WalletRepository repository;
  RequestWithdrawal(this.repository);
  Future<Either<Failures, void>> call({
    required double amount,
    required String payoutAccountId,
  }) {
    return repository.requestWithdrawal(
      amount: amount,
      payoutAccountId: payoutAccountId,
    );
  }
}
