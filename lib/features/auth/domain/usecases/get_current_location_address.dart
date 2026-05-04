import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/domain/entities/customer_address_input.dart';
import 'package:ur_stylist/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentLocationAddress {
  const GetCurrentLocationAddress(this.repository);

  final AuthRepository repository;

  Future<Either<Failures, CustomerAddressInput>> call() {
    return repository.getCurrentLocationAddress();
  }
}
