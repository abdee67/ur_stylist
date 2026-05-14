import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ur_stylist/features/wallet/domain/entities/transaction_entity.dart';

class TransactionListTile extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionListTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final amountPrefix = transaction.isCredit ? '+' : '-';
    final color = transaction.isCredit ? Colors.green : Colors.red;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(
          transaction.isCredit ? Iconsax.arrow_down : Iconsax.arrow_up_3,
          color: color,
        ),
      ),
      title: Text(_title(transaction.source)),
      subtitle: Text(DateFormat('MMM d, h:mm a').format(transaction.createdAt)),
      trailing: Text(
        '$amountPrefix ETB ${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  String _title(String source) {
    return switch (source) {
      'booking_earning' => 'Booking earning',
      'topup' => 'Deposit top up',
      'withdrawal' => 'Withdrawal',
      'penalty' => 'Penalty',
      _ => source,
    };
  }
}
