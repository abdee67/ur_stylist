import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ur_stylist/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:ur_stylist/features/wallet/presentation/widgets/balance_card.dart';
import 'package:ur_stylist/features/wallet/presentation/widgets/deposit_banner.dart';
import 'package:ur_stylist/features/wallet/presentation/widgets/deposit_sheet.dart';
import 'package:ur_stylist/features/wallet/presentation/widgets/transaction_filter_bar.dart';
import 'package:ur_stylist/features/wallet/presentation/widgets/transaction_list_tile.dart';
import 'package:ur_stylist/features/wallet/presentation/widgets/withdraw_sheet.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        final message = state.errorMessage ?? state.successMessage;
        if (message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async =>
              context.read<WalletBloc>().add(const WalletRefreshed()),
          child: BlocBuilder<WalletBloc, WalletState>(
            builder: (context, state) {
              if (state.isLoading && state.wallet == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final wallet = state.wallet;
              if (wallet == null) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: const [Text('Wallet is not available yet.')],
                );
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  BalanceCard(
                    wallet: wallet,
                    onDeposit: () =>
                        _showDeposit(context, wallet.minimumDeposit),
                    onWithdraw: () =>
                        _showWithdraw(context, wallet.withdrawable),
                  ),
                  if (wallet.requiresDeposit) ...[
                    const SizedBox(height: 12),
                    DepositBanner(
                      requiredAmount: wallet.minimumDeposit,
                      onTap: () => _showDeposit(context, wallet.minimumDeposit),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (state.payoutAccount != null)
                    Text(
                      '${state.payoutAccount!.bankName} ${state.payoutAccount!.maskedAccount}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )
                  else
                    const Text(
                      'Add payout details in Settings before withdrawing.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const TransactionFilterBar(),
                  if (state.filteredTransactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(child: Text('No transactions yet.')),
                    )
                  else
                    ...state.filteredTransactions.map(
                      (e) => TransactionListTile(transaction: e),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDeposit(BuildContext context, double minimumAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<WalletBloc>(),
        child: DepositSheet(minimumAmount: minimumAmount),
      ),
    );
  }

  void _showWithdraw(BuildContext context, double withdrawable) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<WalletBloc>(),
        child: WithdrawSheet(withdrawable: withdrawable),
      ),
    );
  }
}
