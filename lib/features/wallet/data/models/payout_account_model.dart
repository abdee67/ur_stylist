import 'package:ur_stylist/features/wallet/domain/entities/payout_account_entity.dart';

class PayoutAccountModel extends PayoutAccountEntity {
  const PayoutAccountModel({
    required super.id,
    required super.stylistId,
    required super.accountHolderName,
    required super.bankName,
    required super.accountNumber,
  });

  factory PayoutAccountModel.fromJson(Map<String, dynamic> json) {
    return PayoutAccountModel(
      id: (json['id'] ?? '').toString(),
      stylistId: (json['stylist_id'] ?? '').toString(),
      accountHolderName: (json['account_holder_name'] ?? '').toString(),
      bankName: (json['bank_name'] ?? '').toString(),
      accountNumber: (json['account_number'] ?? '').toString(),
    );
  }
}
