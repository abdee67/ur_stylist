import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/settings/domain/entities/stylist_profile_entity.dart';
import 'package:ur_stylist/features/settings/domain/repositories/settings_repository.dart';

class LoadSettingsProfile {
  final SettingsRepository repository;
  LoadSettingsProfile(this.repository);
  Future<Either<Failures, StylistProfileEntity>> call() =>
      repository.getProfile();
}

class SaveSettingsProfile {
  final SettingsRepository repository;
  SaveSettingsProfile(this.repository);
  Future<Either<Failures, void>> call({
    required String name,
    required String phone,
    required String businessName,
    String? description,
    File? profilePhoto,
    double? latitude,
    double? longitude,
    required int serviceRadiusKm,
  }) {
    return repository.updateProfile(
      name: name,
      phone: phone,
      businessName: businessName,
      description: description,
      profilePhoto: profilePhoto,
      latitude: latitude,
      longitude: longitude,
      serviceRadiusKm: serviceRadiusKm,
    );
  }
}

class SaveSettingsAvailability {
  final SettingsRepository repository;
  SaveSettingsAvailability(this.repository);
  Future<Either<Failures, void>> call(List<AvailabilitySlot> availability) {
    return repository.saveAvailability(availability);
  }
}

class AddSettingsPortfolioPhotos {
  final SettingsRepository repository;
  AddSettingsPortfolioPhotos(this.repository);
  Future<Either<Failures, void>> call(List<File> photos) {
    return repository.addPortfolioPhotos(photos);
  }
}

class DeleteSettingsPortfolioPhoto {
  final SettingsRepository repository;
  DeleteSettingsPortfolioPhoto(this.repository);
  Future<Either<Failures, void>> call(PortfolioPhotoEntity photo) {
    return repository.deletePortfolioPhoto(photo);
  }
}

class SaveSettingsPayoutAccount {
  final SettingsRepository repository;
  SaveSettingsPayoutAccount(this.repository);
  Future<Either<Failures, void>> call({
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
  }) {
    return repository.savePayoutAccount(
      bankName: bankName,
      accountHolderName: accountHolderName,
      accountNumber: accountNumber,
    );
  }
}

class SaveSettingsPreferences {
  final SettingsRepository repository;
  SaveSettingsPreferences(this.repository);
  Future<Either<Failures, void>> call(Map<String, dynamic> preferences) {
    return repository.updatePreferences(preferences);
  }
}

