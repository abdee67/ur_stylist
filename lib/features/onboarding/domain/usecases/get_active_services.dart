import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/onboarding/domain/entities/service_entity.dart';
import 'package:ur_stylist/features/onboarding/domain/repositories/stylist_onboarding_repository.dart';

class GetActiveServices {
  final StylistOnboardingRepository repository;

  GetActiveServices(this.repository);

  Future<Either<Failures, List<ServiceEntity>>> call() {
    return repository.getActiveServices();
  }
}
