import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/onboarding_state_entity.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/repositories/stylist_onboarding_repository.dart';

class SaveBasicInfo {
  final StylistOnboardingRepository repository;

  SaveBasicInfo(this.repository);

  Future<Either<Failures, String?>> call(OnboardingStateEntity state) {
    return repository.saveBasicInfo(state);
  }
}
