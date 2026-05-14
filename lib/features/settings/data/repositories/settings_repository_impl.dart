import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:ur_stylist/features/settings/domain/entities/stylist_profile_entity.dart';
import 'package:ur_stylist/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failures, StylistProfileEntity>> getProfile() =>
      _guard(remoteDataSource.getProfile);

  @override
  Future<Either<Failures, void>> updateProfile({
    required String name,
    required String phone,
    required String businessName,
    String? description,
    File? profilePhoto,
    double? latitude,
    double? longitude,
    required int serviceRadiusKm,
  }) {
    return _guard(
      () => remoteDataSource.updateProfile(
        name: name,
        phone: phone,
        businessName: businessName,
        description: description,
        profilePhoto: profilePhoto,
        latitude: latitude,
        longitude: longitude,
        serviceRadiusKm: serviceRadiusKm,
      ),
    );
  }

  @override
  Future<Either<Failures, void>> saveAvailability(
    List<AvailabilitySlot> availability,
  ) {
    return _guard(() => remoteDataSource.saveAvailability(availability));
  }

  @override
  Future<Either<Failures, void>> addPortfolioPhotos(List<File> photos) {
    return _guard(() => remoteDataSource.addPortfolioPhotos(photos));
  }

  @override
  Future<Either<Failures, void>> deletePortfolioPhoto(
    PortfolioPhotoEntity photo,
  ) {
    return _guard(() => remoteDataSource.deletePortfolioPhoto(photo));
  }

  @override
  Future<Either<Failures, void>> savePayoutAccount({
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
  }) {
    return _guard(
      () => remoteDataSource.savePayoutAccount(
        bankName: bankName,
        accountHolderName: accountHolderName,
        accountNumber: accountNumber,
      ),
    );
  }

  @override
  Future<Either<Failures, void>> updatePreferences(
    Map<String, dynamic> preferences,
  ) {
    return _guard(() => remoteDataSource.updatePreferences(preferences));
  }

  @override
  Future<Either<Failures, void>> signOut() => _guard(remoteDataSource.signOut);

  @override
  Future<Either<Failures, void>> deactivateAccount() =>
      _guard(remoteDataSource.deactivateAccount);

  Future<Either<Failures, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on PostgrestException catch (e) {
      return Left(Failures(message: _mapError(e.code)));
    } catch (_) {
      return Left(Failures(message: 'Something went wrong. Please try again.'));
    }
  }

  String _mapError(String? code) => switch (code) {
    '23505' => 'This record already exists',
    '42501' => "You don't have permission to do that",
    _ => 'Something went wrong. Please try again.',
  };
}
