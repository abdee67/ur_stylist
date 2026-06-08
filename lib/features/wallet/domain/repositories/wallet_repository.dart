import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/wallet/domain/entities/payout_account_entity.dart';
import 'package:ur_stylist/features/wallet/domain/entities/transaction_entity.dart';
import 'package:ur_stylist/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failures, WalletEntity>> getWallet();
  Future<Either<Failures, List<TransactionEntity>>> getTransactions({
    int limit = 20,
    int offset = 0,
  });
  Future<Either<Failures, PayoutAccountEntity?>> getPayoutAccount();
  Future<Either<Failures, void>> submitDepositProof({
    required double amount,
    required File proof,
  });
  Future<Either<Failures, void>> requestWithdrawal({
    required double amount,
    required String payoutAccountId,
  });
}
