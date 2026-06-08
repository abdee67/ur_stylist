import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:ur_stylist/features/wallet/domain/entities/payout_account_entity.dart';
import 'package:ur_stylist/features/wallet/domain/entities/transaction_entity.dart';
import 'package:ur_stylist/features/wallet/domain/entities/wallet_entity.dart';
import 'package:ur_stylist/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failures, WalletEntity>> getWallet() =>
      _guard(remoteDataSource.getWallet);

  @override
  Future<Either<Failures, List<TransactionEntity>>> getTransactions({
    int limit = 20,
    int offset = 0,
  }) {
    return _guard(
      () => remoteDataSource.getTransactions(limit: limit, offset: offset),
    );
  }

  @override
  Future<Either<Failures, PayoutAccountEntity?>> getPayoutAccount() {
    return _guard(remoteDataSource.getPayoutAccount);
  }

  @override
  Future<Either<Failures, void>> submitDepositProof({
    required double amount,
    required File proof,
  }) {
    return _guard(
      () => remoteDataSource.submitDepositProof(amount: amount, proof: proof),
    );
  }

  @override
  Future<Either<Failures, void>> requestWithdrawal({
    required double amount,
    required String payoutAccountId,
  }) {
    return _guard(
      () => remoteDataSource.requestWithdrawal(
        amount: amount,
        payoutAccountId: payoutAccountId,
      ),
    );
  }

  Future<Either<Failures, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on PostgrestException catch (e) {
      return Left(Failures(message: _mapError(e.code)));
    } catch (_) {
      return Left(Failures(message: 'Something went wrong. Please try again.'));
    }
  }

  String _mapError(String? code) => switch (code) {
    '23505' => 'This record already exists',
    '42501' => "You don't have permission to do that",
    _ => 'Something went wrong. Please try again.',
  };
}
