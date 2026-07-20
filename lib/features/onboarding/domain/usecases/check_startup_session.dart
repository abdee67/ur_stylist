import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/onboarding/domain/repositories/stylist_onboarding_repository.dart';

class CheckStartupSession {
  final StylistOnboardingRepository repository;

  CheckStartupSession(this.repository);

  Future<Either<Failures, String>> call() {
    return repository.checkStartupSession();
  }
}
