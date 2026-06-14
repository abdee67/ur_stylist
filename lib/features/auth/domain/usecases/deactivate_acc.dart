import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/domain/repositories/auth_repository.dart';

class DeactivateAccount {
  final AuthRepository repository;
  DeactivateAccount(this.repository);
  Future<Either<Failures, void>> call() => repository.deactivateAccount();
}