import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/config/supabase_config.dart';
import 'package:ur_stylist/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:ur_stylist/features/wallet/data/models/payout_account_model.dart';
import 'package:ur_stylist/features/wallet/data/models/transaction_model.dart';
import 'package:ur_stylist/features/wallet/data/models/wallet_model.dart';
import 'package:ur_stylist/features/wallet/domain/entities/payout_account_entity.dart';
import 'package:ur_stylist/features/wallet/domain/entities/transaction_entity.dart';
import 'package:ur_stylist/features/wallet/domain/entities/wallet_entity.dart';

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<String> _stylistId() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Please sign in again.');
    final response = await _client
        .from('stylists')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
    if (response == null) throw Exception('You are not a stylist.');
    return response['id'].toString();
  }

  @override
  Future<WalletEntity> getWallet() async {
    final stylistId = await _stylistId();
    final response = await _client
        .from('wallets')
        .select()
        .eq('stylist_id', stylistId)
        .maybeSingle();
    if (response != null) return WalletModel.fromJson(response);
    final inserted = await _client
        .from('wallets')
        .insert({'stylist_id': stylistId, 'balance': 0, 'currency': 'etb'})
        .select()
        .single();
    return WalletModel.fromJson(inserted);
  }

  @override
  Future<List<TransactionEntity>> getTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    final wallet = await getWallet();
    final response = await _client
        .from('wallet_transactions')
        .select()
        .eq('wallet_id', wallet.id)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return (response as List)
        .map(
          (item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<PayoutAccountEntity?> getPayoutAccount() async {
    final stylistId = await _stylistId();
    final response = await _client
        .from('stylist_payout_accounts')
        .select()
        .eq('stylist_id', stylistId)
        .eq('is_primary', true)
        .maybeSingle();
    return response == null ? null : PayoutAccountModel.fromJson(response);
  }

  @override
  Future<void> submitDepositProof({
    required double amount,
    required File proof,
  }) async {
    final wallet = await getWallet();
    final path =
        '${wallet.stylistId}/${DateTime.now().microsecondsSinceEpoch}.jpg';
    final file = await _compress(proof);
    await _client.storage
        .from('deposit-proofs')
        .upload(
          path,
          file,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
    await _client.from('wallet_transactions').insert({
      'wallet_id': wallet.id,
      'transaction_type': 'credit',
      'amount': amount,
      'source': 'topup',
      'metadata': {
        'proof_url': 'deposit-proofs/$path',
        'status': 'pending_verification',
      },
    });
    // TODO: notify admin to verify deposit proof.
  }

  @override
  Future<void> requestWithdrawal({
    required double amount,
    required String payoutAccountId,
  }) async {
    final wallet = await getWallet();
    final reference = 'WITHDRAW-${DateTime.now().millisecondsSinceEpoch}';
    await _client.from('wallet_transactions').insert({
      'wallet_id': wallet.id,
      'transaction_type': 'debit',
      'amount': amount,
      'source': 'withdrawal',
      'reference': reference,
      'metadata': {'status': 'pending', 'payout_account_id': payoutAccountId},
    });
    await _client
        .from('wallets')
        .update({
          'balance': wallet.balance - amount,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', wallet.id);
    await _client.from('payouts').insert({
      'wallet_id': wallet.id,
      'amount': amount,
      'payout_method': 'bank_transfer',
      'status': 'pending',
      'metadata': {'payout_account_id': payoutAccountId},
    });
    // TODO: Chapa/manual payout processing by admin.
  }

  Future<File> _compress(File file) async {
    final targetPath = p.join(
      Directory.systemTemp.path,
      'deposit_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      minWidth: 1200,
      minHeight: 1200,
      quality: 80,
      format: CompressFormat.jpeg,
    );
    return compressed == null ? file : File(compressed.path);
  }
}
