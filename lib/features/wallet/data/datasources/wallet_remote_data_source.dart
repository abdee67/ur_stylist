import 'dart:io';

import 'package:ur_stylist/features/wallet/domain/entities/payout_account_entity.dart';
import 'package:ur_stylist/features/wallet/domain/entities/transaction_entity.dart';
import 'package:ur_stylist/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletRemoteDataSource {
  Future<WalletEntity> getWallet();
  Future<List<TransactionEntity>> getTransactions({
    int limit = 20,
    int offset = 0,
  });
  Future<PayoutAccountEntity?> getPayoutAccount();
  Future<void> submitDepositProof({
    required double amount,
    required File proof,
  });
  Future<void> requestWithdrawal({
    required double amount,
    required String payoutAccountId,
  });
}
