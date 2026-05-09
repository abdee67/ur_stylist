import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_bloc.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_event.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_state.dart';

class Page4Wallet extends StatefulWidget {
  const Page4Wallet({super.key});

  @override
  State<Page4Wallet> createState() => _Page4WalletState();
}

class _Page4WalletState extends State<Page4Wallet> {
  static const banks = [
    'Commercial Bank of Ethiopia',
    'Awash Bank',
    'Abyssinia Bank',
    'Dashen Bank',
    'Bunna Bank',
    'Oromia Bank',
    'Wegagen Bank',
    'United Bank',
    'Nib Bank',
    'Cooperative Bank of Oromia',
  ];

  final _holder = TextEditingController();
  final _account = TextEditingController();
  final _card = TextEditingController();

  @override
  void dispose() {
    _holder.dispose();
    _account.dispose();
    _card.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StylistOnboardingBloc, StylistOnboardingState>(
      builder: (context, state) {
        final data = state.data;
        _sync(_holder, data.accountHolderName ?? data.fullName);
        _sync(_account, data.accountNumber);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Wallet & payout setup',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: banks.contains(data.bankName)
                  ? data.bankName
                  : null,
              items: banks
                  .map(
                    (bank) => DropdownMenuItem(value: bank, child: Text(bank)),
                  )
                  .toList(),
              onChanged: (value) => _changed(bankName: value),
              decoration: const InputDecoration(
                labelText: 'Bank name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _holder,
              onChanged: (value) => _changed(accountHolderName: value),
              decoration: const InputDecoration(
                labelText: 'Account holder name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _account,
              keyboardType: TextInputType.number,
              onChanged: (value) => _changed(accountNumber: value),
              decoration: const InputDecoration(
                labelText: 'Account number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SwitchListTile(
              value: data.addDebitCard,
              onChanged: (value) => _changed(addDebitCard: value),
              title: const Text(
                'Add a debit card for faster payouts (optional)',
              ),
              subtitle: const Text(
                'Only the last 4 digits are saved in this version.',
              ),
            ),
            if (data.addDebitCard) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _card,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 16,
                onChanged: (value) => _changed(cardNumber: value),
                decoration: const InputDecoration(
                  labelText: 'Card number (optional)',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Expiry and cardholder name will be tokenized through Chapa in production.',
                style: TextStyle(fontSize: 12),
              ),
            ],
            const SizedBox(height: 18),
            Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SingleChildScrollView(
                child: Text(
                  'Platform service fee: 15% per completed booking.\n\n'
                  'Payout schedule: weekly every Monday for eligible completed bookings.\n\n'
                  'Cancellation policy: late cancellations and no-shows may affect payouts according to the platform terms.',
                ),
              ),
            ),
            TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (context) => const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Full terms will be connected to the legal document before launch. '
                    'This onboarding stores bank account details only. Do not enter PIN, CVV, or card secrets.',
                  ),
                ),
              ),
              child: const Text('Read full terms'),
            ),
            CheckboxListTile(
              value: data.termsAccepted,
              onChanged: (value) => _changed(termsAccepted: value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'I agree to the terms of service and platform fee policy',
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: data.canSubmitWallet
                    ? () {
                        context.read<StylistOnboardingBloc>().add(
                          const WalletSubmitted(),
                        );
                      }
                    : null,
                child: const Text('Submit for review'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _changed({
    String? bankName,
    String? accountHolderName,
    String? accountNumber,
    bool? termsAccepted,
    bool? addDebitCard,
    String? cardNumber,
  }) {
    context.read<StylistOnboardingBloc>().add(
      WalletInfoChanged(
        bankName: bankName,
        accountHolderName: accountHolderName ?? _holder.text.trim(),
        accountNumber: accountNumber ?? _account.text.trim(),
        termsAccepted: termsAccepted,
        addDebitCard: addDebitCard,
        cardNumber: cardNumber,
      ),
    );
    // TODO: Chapa integration should tokenize optional debit cards in production.
  }

  void _sync(TextEditingController controller, String? value) {
    final next = value ?? '';
    if (next.isNotEmpty && controller.text != next) {
      controller.text = next;
    }
  }
}
