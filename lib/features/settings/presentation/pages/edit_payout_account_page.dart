import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ur_stylist/features/wallet/domain/entities/payout_account_entity.dart';
import 'package:ur_stylist/features/settings/presentation/bloc/settings_bloc.dart';

class EditPayoutAccountPage extends StatefulWidget {
  final PayoutAccountEntity? account;

  const EditPayoutAccountPage({super.key, this.account});

  @override
  State<EditPayoutAccountPage> createState() => _EditPayoutAccountPageState();
}

class _EditPayoutAccountPageState extends State<EditPayoutAccountPage> {
  late final TextEditingController _bank;
  late final TextEditingController _holder;
  late final TextEditingController _number;

  @override
  void initState() {
    super.initState();
    _bank = TextEditingController(text: widget.account?.bankName ?? '');
    _holder = TextEditingController(
      text: widget.account?.accountHolderName ?? '',
    );
    _number = TextEditingController(text: widget.account?.accountNumber ?? '');
  }

  @override
  void dispose() {
    _bank.dispose();
    _holder.dispose();
    _number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payout account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _bank,
            decoration: const InputDecoration(labelText: 'Bank name'),
          ),
          TextField(
            controller: _holder,
            decoration: const InputDecoration(labelText: 'Account holder'),
          ),
          TextField(
            controller: _number,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Account number'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save payout account'),
          ),
        ],
      ),
    );
  }

  void _save() {
    context.read<SettingsBloc>().add(
      SettingsPayoutSaved(
        bankName: _bank.text.trim(),
        accountHolderName: _holder.text.trim(),
        accountNumber: _number.text.trim(),
      ),
    );
    Navigator.pop(context);
  }
}
