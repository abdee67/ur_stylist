import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/data/datasources/auth_location_data_source.dart';
import 'package:ur_stylist/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ur_stylist/features/auth/data/models/customer_model.dart';
import 'package:ur_stylist/features/auth/data/models/customer_address_model.dart';
import 'package:ur_stylist/features/auth/domain/entities/customer_address_input.dart';
import 'package:ur_stylist/features/auth/domain/entities/customer_entity.dart';
import 'package:ur_stylist/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocationDataSource locationDataSource;
  AuthRepositoryImpl(this.remoteDataSource, this.locationDataSource);
  @override
  Future<Either<Failures, Session>> signIn(
    String email,
    String password,
  ) async => _guard(() => remoteDataSource.signIn(email, password));

  @override
  Future<Either<Failures, void>> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String phone,
    CustomerAddressInput address,
  ) async => _guard(() => remoteDataSource.signUp(
        email,
        password,
        firstName,
        lastName,
        phone,
        address,
      ));



  @override
  Future<Either<Failures, void>> sendOtp(String email) =>
      _guard(() => remoteDataSource.sendOtp(email));


  @override
  Future<Either<Failures, void>> verifyOtp(String email, String otp) =>
      _guard(() => remoteDataSource.verifyOTP(email, otp));

  @override
  Future<Either<Failures, void>> signOut() =>
      _guard(remoteDataSource.signOut);
  
  @override
  Future<Either<Failures, void>> deactivateAccount() =>

      _guard(remoteDataSource.deactivateAccount);

  @override
  Future<Either<Failures, CustomerModel>> getCurrentCustomer() async =>
      _guard(remoteDataSource.getCurrentCustomer);

  @override
  Future<Either<Failures, CustomerEntity>> updateCustomerProfile(
    CustomerEntity client,
  ) async {
    final clientModel = CustomerModel(
        id: client.id,
        email: client.email,
        firstName: client.firstName,
        lastName: client.lastName,
        phone: client.phone,
      );
    return _guard(() => remoteDataSource.updateCustomerProfile(clientModel));
  }

  @override
  Future<Either<Failures, void>> forgotPassword(String email) =>
      _guard(() => remoteDataSource.forgotPassword(email));

  @override
  Future<Either<Failures, void>> resetPassword(
    String email,
    String password,
  ) =>
      _guard(() => remoteDataSource.resetPassword(email, password));

  @override
  Future<Either<Failures, CustomerAddressInput>>
  getCurrentLocationAddress() =>
      _guard(locationDataSource.getCurrentLocationAddress);

  @override
  Future<Either<Failures, CustomerAddressModel>> createCustomerAddress(
    CustomerAddressInput input,
  ) => _guard(() => remoteDataSource.createCustomerAddress(input.toJson()));
  
  Future<Either<Failures, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on PostgrestException catch (e) {
      return Left(Failures(message: _mapError(e.code)));
    } catch (e) {
      if(kDebugMode) {
        developer.log(e.toString());
      }
      return Left(Failures(message: 'Something went wrong. Please try again.'));
    
    }
  }
  
  String _mapError(String? code) => switch (code) {
    '23505' => 'This record already exists',
    '42501' => "You don't have permission to do that",
    _ => 'Something went wrong. Please try again.',
      
  };
}
