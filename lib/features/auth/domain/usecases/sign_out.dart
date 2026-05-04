import 'package:dartz/dartz.dart';

import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/domain/repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repo;
  SignOut(this.repo);

  Future<Either<Failures, void>> call() {
    return repo.signOut();
  }
}
