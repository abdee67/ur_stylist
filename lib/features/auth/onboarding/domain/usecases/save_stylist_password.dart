import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/repositories/stylist_onboarding_repository.dart';

class SaveStylistPassword {
  final StylistOnboardingRepository repository;

  SaveStylistPassword(this.repository);

  Future<Either<Failures, void>> call({
    required String stylistId,
    required String password,
  }) {
    return repository.savePassword(stylistId: stylistId, password: password);
  }
}
