import 'package:ur_stylist/features/wallet/domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.stylistId,
    required super.balance,
    required super.currency,
    required super.securityDeposit,
    required super.minimumDeposit,
    required super.depositVerified,
    required super.isActive,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: (json['id'] ?? '').toString(),
      stylistId: (json['stylist_id'] ?? '').toString(),
      balance: double.tryParse((json['balance'] ?? '0').toString()) ?? 0,
      currency: (json['currency'] ?? 'etb').toString(),
      securityDeposit:
          double.tryParse((json['security_deposit'] ?? '0').toString()) ?? 0,
      minimumDeposit:
          double.tryParse((json['minimum_deposit'] ?? '500').toString()) ?? 500,
      depositVerified: json['deposit_verified'] == true,
      isActive: json['is_active'] == true,
    );
  }
}
