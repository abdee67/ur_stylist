import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/repositories/stylist_onboarding_repository.dart';

class SignOutStylist {
  final StylistOnboardingRepository repository;

  SignOutStylist(this.repository);

  Future<Either<Failures, void>> call() {
    return repository.signOut();
  }
}
