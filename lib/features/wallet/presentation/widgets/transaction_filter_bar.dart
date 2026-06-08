import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ur_stylist/features/wallet/presentation/bloc/wallet_bloc.dart';

class TransactionFilterBar extends StatelessWidget {
  const TransactionFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    const filters = {
      'all': 'All',
      'earnings': 'Earnings',
      'deposits': 'Deposits',
      'withdrawals': 'Withdrawals',
    };
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (previous, current) => previous.filter != current.filter,
      builder: (context, state) {
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: filters.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: state.filter == entry.key,
                  label: Text(entry.value),
                  onSelected: (_) => context.read<WalletBloc>().add(
                    WalletFilterChanged(entry.key),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
