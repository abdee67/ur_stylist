import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ur_stylist/features/wallet/domain/entities/wallet_entity.dart';

class BalanceCard extends StatelessWidget {
  final WalletEntity wallet;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  const BalanceCard({
    super.key,
    required this.wallet,
    required this.onDeposit,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available balance',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'ETB ${wallet.balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Security deposit ETB ${wallet.securityDeposit.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDeposit,
                  icon: const Icon(Iconsax.receipt_add, size: 18),
                  label: const Text('Deposit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: wallet.withdrawable > 0 ? onWithdraw : null,
                  icon: const Icon(Iconsax.export_3, size: 18),
                  label: const Text('Withdraw'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
