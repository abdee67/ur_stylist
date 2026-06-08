import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ur_stylist/core/constants/app_routes.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_bloc.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_event.dart';

class OnboardingSubmitted extends StatelessWidget {
  final bool rejected;
  final String? rejectionReason;

  const OnboardingSubmitted({
    super.key,
    this.rejected = false,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 64,
                backgroundColor: rejected
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                child: Icon(
                  rejected
                      ? Icons.assignment_late_outlined
                      : Icons.verified_outlined,
                  size: 72,
                  color: rejected ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                rejected ? 'Needs a few updates' : "You're all set!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                rejected
                    ? (rejectionReason?.isNotEmpty == true
                          ? rejectionReason!
                          : 'Your application needs updated documents before review can continue.')
                    : "We've received your application. Our team will review your documents within 1-3 business days. You'll receive an email and app notification once approved.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, height: 1.45),
              ),
              const SizedBox(height: 28),
              if (rejected)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<StylistOnboardingBloc>().add(
                        const RejectedResubmitRequested(),
                      );
                    },
                    child: const Text('Resubmit documents'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<StylistOnboardingBloc>().add(
                        const SubmittedSignOutRequested(),
                      );
                      context.go(AppRoutes.loginScreen);
                    },
                    child: const Text('Got it'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
