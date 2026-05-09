import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/onboarding/data/datasources/stylist_onboarding_remote_data_source.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/onboarding_state_entity.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/service_entity.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/repositories/stylist_onboarding_repository.dart';

class StylistOnboardingRepositoryImpl implements StylistOnboardingRepository {
  final StylistOnboardingRemoteDataSource remoteDataSource;

  StylistOnboardingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failures, OnboardingStateEntity>>
  loadExistingOnboarding() async {
    try {
      return Right(await remoteDataSource.loadExistingOnboarding());
    } catch (e) {
      return Left(Failures(message: _friendlyMessage(e)));
    }
  }

  @override
  Future<Either<Failures, String?>> saveBasicInfo(
    OnboardingStateEntity state,
  ) async {
    try {
      return Right(await remoteDataSource.saveBasicInfo(state));
    } catch (e) {
      return Left(Failures(message: _friendlyMessage(e)));
    }
  }

  @override
  Future<Either<Failures, String>> verifyEmailOtp({
    required String email,
    required String otp,
    required OnboardingStateEntity state,
  }) async {
    try {
      return Right(
        await remoteDataSource.verifyEmailOtp(
          email: email,
          otp: otp,
          state: state,
        ),
      );
    } catch (e) {
      return Left(Failures(message: _friendlyMessage(e)));
    }
  }

  @override
  Future<Either<Failures, void>> resendOtp(String email) async {
    try {
      await remoteDataSource.resendOtp(email);
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: _friendlyMessage(e)));
    }
  }

  @override
  Future<Either<Failures, void>> saveKyc({
    required String stylistId,
    required File nationalIdFront,
    required File nationalIdBack,
    required File selfieFile,
  }) async {
    try {
      await remoteDataSource.saveKyc(
        stylistId: stylistId,
        nationalIdFront: nationalIdFront,
        nationalIdBack: nationalIdBack,
        selfieFile: selfieFile,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: _friendlyMessage(e)));
    }
  }

  @override
  Future<Either<Failures, List<ServiceEntity>>> getActiveServices() async {
    try {
      return Right(await remoteDataSource.getActiveServices());
    } catch (e) {
      return Left(Failures(message: _friendlyMessage(e)));
    }
  }

  @override
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
  }) async {
    try {
      return Right(
        await remoteDataSource.saveProfessionalDetails(
          stylistId: stylistId,
          licenseFile: licenseFile,
          yearsExperience: yearsExperience,
          selectedServiceIds: selectedServiceIds,
          servicePrices: servicePrices,
          availability: availability,
          serviceRadiusKm: serviceRadiusKm,
          portfolioPhotos: portfolioPhotos,
          onProgress: onProgress,
        ),
      );
    } catch (e) {
      return Left(Failures(message: _friendlyMessage(e)));
    }
  }

  @override
  Future<Either<Failures, void>> submitWallet({
    required String stylistId,
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    String? cardLast4,
    String? cardType,
  }) async {
    try {
      await remoteDataSource.submitWallet(
        stylistId: stylistId,
        bankName: bankName,
        accountHolderName: accountHolderName,
        accountNumber: accountNumber,
        cardLast4: cardLast4,
        cardType: cardType,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: _friendlyMessage(e)));
    }
  }

  @override
  Future<Either<Failures, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: _friendlyMessage(e)));
    }
  }

  String _friendlyMessage(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '');
    final lower = text.toLowerCase();
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Please check your internet connection and try again.';
    }
    if (lower.contains('otp') || lower.contains('token')) {
      return 'That verification code did not work. Please check it and try again.';
    }
    if (lower.contains('storage')) {
      return 'We could not upload your file. Please try again.';
    }
    if (lower.contains('duplicate')) {
      return 'This information already exists. Please sign in or continue onboarding.';
    }
    return text.isEmpty ? 'Something went wrong. Please try again.' : text;
  }
}
