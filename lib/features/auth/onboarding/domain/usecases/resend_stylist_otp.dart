import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/repositories/stylist_onboarding_repository.dart';

class ResendStylistOtp {
  final StylistOnboardingRepository repository;

  ResendStylistOtp(this.repository);

  Future<Either<Failures, void>> call(String email) {
    return repository.resendOtp(email);
  }
}
