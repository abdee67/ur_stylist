import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DepositBanner extends StatelessWidget {
  final double requiredAmount;
  final VoidCallback onTap;

  const DepositBanner({
    super.key,
    required this.requiredAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.shield_tick, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Submit and verify ETB ${requiredAmount.toStringAsFixed(0)} security deposit to receive bookings.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
