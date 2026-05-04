import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/domain/repositories/auth_repository.dart';
import 'package:ur_stylist/features/auth/domain/entities/customer_address_input.dart';
import 'package:ur_stylist/features/auth/domain/entities/customer_address_entity.dart';

class CreateCustomerAddress {
  final AuthRepository repo;
  CreateCustomerAddress(this.repo);

  Future<Either<Failures, CustomerAddressEntity>> call(
    CustomerAddressInput input,
  ) {
    return repo.createCustomerAddress(input);
  }
}
