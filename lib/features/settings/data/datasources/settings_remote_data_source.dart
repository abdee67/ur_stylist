import 'dart:io';

import 'package:ur_stylist/features/auth/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/settings/domain/entities/stylist_profile_entity.dart';

abstract class SettingsRemoteDataSource {
  Future<StylistProfileEntity> getProfile();
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String businessName,
    String? description,
    File? profilePhoto,
    double? latitude,
    double? longitude,
    required int serviceRadiusKm,
  });
  Future<void> saveAvailability(List<AvailabilitySlot> availability);
  Future<void> addPortfolioPhotos(List<File> photos);
  Future<void> deletePortfolioPhoto(PortfolioPhotoEntity photo);
  Future<void> savePayoutAccount({
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
  });
  Future<void> updatePreferences(Map<String, dynamic> preferences);
  Future<void> signOut();
  Future<void> deactivateAccount();
}
