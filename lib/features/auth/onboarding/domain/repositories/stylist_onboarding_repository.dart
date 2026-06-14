import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/onboarding_state_entity.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/service_entity.dart';

abstract class StylistOnboardingRepository {
  Future<Either<Failures, OnboardingStateEntity>> loadExistingOnboarding();

  Future<Either<Failures, String?>> saveBasicInfo(OnboardingStateEntity state);

  Future<Either<Failures, String>> verifyEmailOtp({
    required String email,
    required String otp,
    required OnboardingStateEntity state,
  });

  Future<Either<Failures, void>> resendOtp(String email);

  Future<Either<Failures, void>> saveKyc({
    required String stylistId,
    required File nationalIdFront,
    required File nationalIdBack,
    required File selfieFile,
  });

  Future<Either<Failures, List<ServiceEntity>>> getActiveServices();

  Future<Either<Failures, String?>> saveProfessionalDetails({
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

  Future<Either<Failures, void>> submitWallet({
    required String stylistId,
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    String? cardLast4,
    String? cardType,
  });

  Future<Either<Failures, void>> savePassword({
    required String stylistId,
    required String password,
  });

  Future<Either<Failures, void>> signOut();

  Future<Either<Failures, String>> checkStartupSession();
}
