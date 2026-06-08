import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AccountStatusBanner extends StatelessWidget {
  final String status;

  const AccountStatusBanner({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final approved = status == 'approved';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: approved ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: approved ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            approved ? Iconsax.verify : Iconsax.info_circle,
            color: approved ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              approved
                  ? 'Approved stylist account'
                  : 'Account status: ${status.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
