import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/onboarding/domain/entities/onboarding_state_entity.dart';
import 'package:ur_stylist/features/onboarding/domain/repositories/stylist_onboarding_repository.dart';

class VerifyStylistOtp {
  final StylistOnboardingRepository repository;

  VerifyStylistOtp(this.repository);

  Future<Either<Failures, String>> call({
    required String email,
    required String otp,
    required OnboardingStateEntity state,
  }) {
    return repository.verifyEmailOtp(email: email, otp: otp, state: state);
  }
}
