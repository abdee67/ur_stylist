import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/settings/domain/entities/stylist_profile_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failures, StylistProfileEntity>> getProfile();
  Future<Either<Failures, void>> updateProfile({
    required String name,
    required String phone,
    required String businessName,
    String? description,
    File? profilePhoto,
    double? latitude,
    double? longitude,
    required int serviceRadiusKm,
  });
  Future<Either<Failures, void>> saveAvailability(
    List<AvailabilitySlot> availability,
  );
  Future<Either<Failures, void>> addPortfolioPhotos(List<File> photos);
  Future<Either<Failures, void>> deletePortfolioPhoto(
    PortfolioPhotoEntity photo,
  );
  Future<Either<Failures, void>> savePayoutAccount({
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
  });
  Future<Either<Failures, void>> updatePreferences(
    Map<String, dynamic> preferences,
  );
}
