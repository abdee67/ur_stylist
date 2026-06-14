import 'dart:io';

import 'package:ur_stylist/features/auth/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/onboarding_state_entity.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/service_entity.dart';

abstract class StylistOnboardingRemoteDataSource {
  Future<OnboardingStateEntity> loadExistingOnboarding();

  Future<String?> saveBasicInfo(OnboardingStateEntity state);

  Future<String> verifyEmailOtp({
    required String email,
    required String otp,
    required OnboardingStateEntity state,
  });

  Future<void> resendOtp(String email);

  Future<void> saveKyc({
    required String stylistId,
    required File nationalIdFront,
    required File nationalIdBack,
    required File selfieFile,
  });

  Future<List<ServiceEntity>> getActiveServices();

  Future<String?> saveProfessionalDetails({
    required String stylistId,
    required File licenseFile,
    required int yearsExperience,
    required List<String> selectedServiceIds,
    required Map<String, double> servicePrices,
    required List<AvailabilitySlot> availability,
    required int serviceRadiusKm,
    required List<File> portfolioPhotos,
    required void Function(double progress) onProgress,
  });

  Future<void> submitWallet({
    required String stylistId,
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    String? cardLast4,
    String? cardType,
  });

  Future<void> savePassword({
    required String stylistId,
    required String password,
  });

  Future<void> signOut();

  Future<String> checkStartupSession();
}
