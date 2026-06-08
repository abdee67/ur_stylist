import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/repositories/stylist_onboarding_repository.dart';

class SaveKyc {
  final StylistOnboardingRepository repository;

  SaveKyc(this.repository);

  Future<Either<Failures, void>> call({
    required String stylistId,
    required File nationalIdFront,
    required File nationalIdBack,
    required File selfieFile,
  }) {
    return repository.saveKyc(
      stylistId: stylistId,
      nationalIdFront: nationalIdFront,
      nationalIdBack: nationalIdBack,
      selfieFile: selfieFile,
    );
  }
}
