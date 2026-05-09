import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/repositories/stylist_onboarding_repository.dart';

class SaveProfessionalDetails {
  final StylistOnboardingRepository repository;

  SaveProfessionalDetails(this.repository);

  Future<Either<Failures, String?>> call({
    required String stylistId,
    required File licenseFile,
    required int yearsExperience,
    required List<String> selectedServiceIds,
    required Map<String, double> servicePrices,
    required List<AvailabilitySlot> availability,
    required int serviceRadiusKm,
    required List<File> portfolioPhotos,
    required void Function(double progress) onProgress,
  }) {
    return repository.saveProfessionalDetails(
      stylistId: stylistId,
      licenseFile: licenseFile,
      yearsExperience: yearsExperience,
      selectedServiceIds: selectedServiceIds,
      servicePrices: servicePrices,
      availability: availability,
      serviceRadiusKm: serviceRadiusKm,
      portfolioPhotos: portfolioPhotos,
      onProgress: onProgress,
    );
  }
}
