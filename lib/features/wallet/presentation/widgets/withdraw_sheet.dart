import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ur_stylist/features/wallet/presentation/bloc/wallet_bloc.dart';

class WithdrawSheet extends StatefulWidget {
  final double withdrawable;

  const WithdrawSheet({super.key, required this.withdrawable});

  @override
  State<WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<WithdrawSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request withdrawal',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('Available ETB ${widget.withdrawable.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: 'ETB ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.isActionLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  child: state.isActionLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Request payout'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final amount = double.tryParse(_controller.text.trim()) ?? 0;
    context.read<WalletBloc>().add(WithdrawalRequested(amount));
    Navigator.pop(context);
  }
}
