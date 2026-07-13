import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ur_stylist/core/constants/app_routes.dart';
import 'package:ur_stylist/features/onboarding/domain/entities/onboarding_flow_status.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_bloc.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_event.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_state.dart';
import 'package:ur_stylist/features/onboarding/presentation/pages/onboarding_submitted.dart';
import 'package:ur_stylist/features/onboarding/presentation/pages/page1_basic_info.dart';
import 'package:ur_stylist/features/onboarding/presentation/pages/page1b_email_otp.dart';
import 'package:ur_stylist/features/onboarding/presentation/pages/page2_kyc.dart';
import 'package:ur_stylist/features/onboarding/presentation/pages/page3_professional.dart';
import 'package:ur_stylist/features/onboarding/presentation/pages/page4_wallet.dart';
import 'package:ur_stylist/features/onboarding/presentation/pages/page5_create_password.dart';
import 'package:ur_stylist/features/onboarding/presentation/widgets/wizard_progress_bar.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  @override
  void initState() {
    super.initState();
    context.read<StylistOnboardingBloc>().add(const OnboardingStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StylistOnboardingBloc, StylistOnboardingState>(
      listener: (context, state) {
        final message = state.data.errorMessage ?? state.data.warningMessage;
        if (message != null && message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: state.data.errorMessage == null
                  ? Colors.orange.shade700
                  : Colors.red.shade500,
            ),
          );
          context.read<StylistOnboardingBloc>().add(
            const OnboardingMessageCleared(),
          );
        }

        if (state.data.flowStatus == OnboardingFlowStatus.approved) {
          context.go(AppRoutes.homeScreen);
        }
      },
      builder: (context, state) {
        final data = state.data;
        if (data.flowStatus == OnboardingFlowStatus.pendingReview ||
            data.flowStatus == OnboardingFlowStatus.submitted) {
          return const OnboardingSubmitted();
        }
        if (data.flowStatus == OnboardingFlowStatus.rejected) {
          return OnboardingSubmitted(
            rejected: true,
            rejectionReason: data.rejectionReason,
          );
        }

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: const Text('Stylist Onboarding'),
                leading: data.currentStep > 1
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          context.read<StylistOnboardingBloc>().add(
                            const OnboardingBackPressed(),
                          );
                        },
                      )
                    : null,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: WizardProgressBar(currentStep: data.currentStep),
                    ),
                    if (data.uploadProgress > 0 && data.uploadProgress < 1)
                      LinearProgressIndicator(value: data.uploadProgress),
                    Expanded(child: _pageForStep(data.currentStep)),
                  ],
                ),
              ),
            ),
            if (data.isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _pageForStep(int step) {
    switch (step) {
      case 1:
        return const Page1bEmailOtp();
      case 2:
        return const Page2Kyc();
      case 3:
        return const Page3Professional();
      case 4:
        return const Page4Wallet();
      case 5:
        return const Page5CreatePassword();
      default:
        return const Page1BasicInfo();
    }
  }
}
