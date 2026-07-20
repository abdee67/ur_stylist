import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_bloc.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_event.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_state.dart';

class Page1bEmailOtp extends StatefulWidget {
  const Page1bEmailOtp({super.key});

  @override
  State<Page1bEmailOtp> createState() => _Page1bEmailOtpState();
}

class _Page1bEmailOtpState extends State<Page1bEmailOtp> {
  String _otp = '';
  int _cooldown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StylistOnboardingBloc, StylistOnboardingState>(
      builder: (context, state) {
        final email = state.data.email ?? 'your email';
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 52,
              backgroundColor: Colors.pink.shade50,
              child: Icon(
                Icons.mark_email_read,
                size: 54,
                color: Colors.pink.shade400,
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'Check your email',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'We sent a 6 digit verification code to\n$email',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 28),
            PinCodeTextField(
              appContext: context,
              length: 6,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 52,
                fieldWidth: 44,
                activeFillColor: Colors.white,
                selectedColor: Colors.pink,
                activeColor: Colors.pink,
                inactiveColor: Colors.grey.shade300,
              ),
              onChanged: (value) => _otp = value,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _otp.length == 6
                    ? () {
                        context.read<StylistOnboardingBloc>().add(
                          OtpSubmitted(_otp),
                        );
                      }
                    : null,
                child: const Text('Verify email'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _cooldown == 0
                  ? () {
                      context.read<StylistOnboardingBloc>().add(
                        const OtpResent(),
                      );
                      _startCooldown();
                    }
                  : null,
              child: Text(
                _cooldown == 0 ? 'Resend code' : 'Resend code in $_cooldown s',
              ),
            ),
          ],
        );
      },
    );
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }
}
