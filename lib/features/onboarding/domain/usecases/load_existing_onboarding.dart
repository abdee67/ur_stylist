import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/onboarding/domain/entities/onboarding_state_entity.dart';
import 'package:ur_stylist/features/onboarding/domain/repositories/stylist_onboarding_repository.dart';

class LoadExistingOnboarding {
  final StylistOnboardingRepository repository;

  LoadExistingOnboarding(this.repository);

  Future<Either<Failures, OnboardingStateEntity>> call() {
    return repository.loadExistingOnboarding();
  }
}
