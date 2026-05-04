import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/domain/repositories/auth_repository.dart';

import '../entities/customer_entity.dart';

class GetCurrentCustomer {
  final AuthRepository repo;
  GetCurrentCustomer(this.repo);

  Future<Either<Failures, CustomerEntity>> call() {
    return repo.getCurrentCustomer();
  }
}
