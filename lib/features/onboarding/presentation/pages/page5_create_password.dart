import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_bloc.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_event.dart';
import 'package:ur_stylist/features/auth/presentation/widgets/password_strength_meter.dart';

class Page5CreatePassword extends StatefulWidget {
  const Page5CreatePassword({super.key});

  @override
  State<Page5CreatePassword> createState() => _Page5CreatePasswordState();
}

class _Page5CreatePasswordState extends State<Page5CreatePassword> {
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _hasMinimumLength => _password.text.trim().length >= 8;
  bool get _hasLetter => RegExp(r'[A-Za-z]').hasMatch(_password.text);
  bool get _hasNumber => RegExp(r'\d').hasMatch(_password.text);
  bool get _matches =>
      _password.text.trim().isNotEmpty &&
      _password.text.trim() == _confirmPassword.text.trim();
  bool get _canSubmit =>
      _hasMinimumLength && _hasLetter && _hasNumber && _matches;

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Create your password',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'This lets you sign in later with email and password. You can still use email code sign-in too.',
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _password,
          obscureText: _obscurePassword,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        PasswordStrengthMeter(password: _password.text),
        const SizedBox(height: 14),
        _RuleRow(isMet: _hasMinimumLength, text: 'At least 8 characters'),
        _RuleRow(isMet: _hasLetter, text: 'Includes a letter'),
        _RuleRow(isMet: _hasNumber, text: 'Includes a number'),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmPassword,
          obscureText: _obscureConfirmPassword,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'Confirm password',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_reset),
            suffixIcon: IconButton(
              onPressed: () {
                setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                );
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _RuleRow(isMet: _matches, text: 'Passwords match'),
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _canSubmit ? _submit : null,
            child: const Text('Submit for review'),
          ),
        ),
      ],
    );
  }

  void _submit() {
    context.read<StylistOnboardingBloc>().add(
      PasswordSubmitted(
        password: _password.text,
        confirmPassword: _confirmPassword.text,
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final bool isMet;
  final String text;

  const _RuleRow({required this.isMet, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
