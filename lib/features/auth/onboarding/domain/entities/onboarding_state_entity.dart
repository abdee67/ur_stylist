import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/onboarding_flow_status.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/service_entity.dart';

class OnboardingStateEntity extends Equatable {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? businessName;
  final File? profilePhoto;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final String? locationError;
  final bool isFetchingLocation;
  final File? nationalIdFront;
  final File? nationalIdBack;
  final File? selfieFile;
  final String? selfieImagePath;
  final bool selfieVerified;
  final File? licenseFile;
  final int yearsExperience;
  final List<String> selectedServiceIds;
  final Map<String, double> servicePrices;
  final List<ServiceEntity> services;
  final List<AvailabilitySlot> availability;
  final int serviceRadiusKm;
  final List<File> portfolioPhotos;
  final String? bankName;
  final String? accountHolderName;
  final String? accountNumber;
  final bool addDebitCard;
  final String? cardLast4;
  final String? cardType;
  final bool termsAccepted;
  final int currentStep;
  final bool isLoading;
  final double uploadProgress;
  final String? errorMessage;
  final String? warningMessage;
  final String? stylistId;
  final String? rejectionReason;
  final OnboardingFlowStatus flowStatus;

  const OnboardingStateEntity({
    this.fullName,
    this.email,
    this.phone,
    this.businessName,
    this.profilePhoto,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.locationError,
    this.isFetchingLocation = false,
    this.nationalIdFront,
    this.nationalIdBack,
    this.selfieFile,
    this.selfieImagePath,
    this.selfieVerified = false,
    this.licenseFile,
    this.yearsExperience = 0,
    this.selectedServiceIds = const [],
    this.servicePrices = const {},
    this.services = const [],
    this.availability = const [],
    this.serviceRadiusKm = 10,
    this.portfolioPhotos = const [],
    this.bankName,
    this.accountHolderName,
    this.accountNumber,
    this.addDebitCard = false,
    this.cardLast4,
    this.cardType,
    this.termsAccepted = false,
    this.currentStep = 0,
    this.isLoading = false,
    this.uploadProgress = 0,
    this.errorMessage,
    this.warningMessage,
    this.stylistId,
    this.rejectionReason,
    this.flowStatus = OnboardingFlowStatus.unknown,
  });

  factory OnboardingStateEntity.initial() {
    return OnboardingStateEntity(
      availability: AvailabilitySlot.defaultWeek(),
      flowStatus: OnboardingFlowStatus.unknown,
    );
  }

  OnboardingStateEntity copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? businessName,
    File? profilePhoto,
    bool clearProfilePhoto = false,
    double? latitude,
    double? longitude,
    String? locationAddress,
    String? locationError,
    bool clearLocationError = false,
    bool? isFetchingLocation,
    File? nationalIdFront,
    bool clearNationalIdFront = false,
    File? nationalIdBack,
    bool clearNationalIdBack = false,
    File? selfieFile,
    bool clearSelfieFile = false,
    String? selfieImagePath,
    bool clearSelfieImagePath = false,
    bool? selfieVerified,
    File? licenseFile,
    bool clearLicenseFile = false,
    int? yearsExperience,
    List<String>? selectedServiceIds,
    Map<String, double>? servicePrices,
    List<ServiceEntity>? services,
    List<AvailabilitySlot>? availability,
    int? serviceRadiusKm,
    List<File>? portfolioPhotos,
    String? bankName,
    String? accountHolderName,
    String? accountNumber,
    bool? addDebitCard,
    String? cardLast4,
    String? cardType,
    bool clearCard = false,
    bool? termsAccepted,
    int? currentStep,
    bool? isLoading,
    double? uploadProgress,
    String? errorMessage,
    bool clearError = false,
    String? warningMessage,
    bool clearWarning = false,
    String? stylistId,
    String? rejectionReason,
    OnboardingFlowStatus? flowStatus,
  }) {
    return OnboardingStateEntity(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      profilePhoto: clearProfilePhoto
          ? null
          : profilePhoto ?? this.profilePhoto,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress,
      locationError: clearLocationError
          ? null
          : locationError ?? this.locationError,
      isFetchingLocation: isFetchingLocation ?? this.isFetchingLocation,
      nationalIdFront: clearNationalIdFront
          ? null
          : nationalIdFront ?? this.nationalIdFront,
      nationalIdBack: clearNationalIdBack
          ? null
          : nationalIdBack ?? this.nationalIdBack,
      selfieFile: clearSelfieFile ? null : selfieFile ?? this.selfieFile,
      selfieImagePath: clearSelfieImagePath
          ? null
          : selfieImagePath ?? this.selfieImagePath,
      selfieVerified: selfieVerified ?? this.selfieVerified,
      licenseFile: clearLicenseFile ? null : licenseFile ?? this.licenseFile,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
      servicePrices: servicePrices ?? this.servicePrices,
      services: services ?? this.services,
      availability: availability ?? this.availability,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      portfolioPhotos: portfolioPhotos ?? this.portfolioPhotos,
      bankName: bankName ?? this.bankName,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      addDebitCard: addDebitCard ?? this.addDebitCard,
      cardLast4: clearCard ? null : cardLast4 ?? this.cardLast4,
      cardType: clearCard ? null : cardType ?? this.cardType,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      warningMessage: clearWarning
          ? null
          : warningMessage ?? this.warningMessage,
      stylistId: stylistId ?? this.stylistId,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      flowStatus: flowStatus ?? this.flowStatus,
    );
  }

  bool get canContinueBasicInfo {
    return (fullName?.trim().length ?? 0) >= 2 &&
        (email?.contains('@') ?? false) &&
        (phone?.trim().length ?? 0) >= 9 &&
        (businessName?.trim().isNotEmpty ?? false) &&
        latitude != null &&
        longitude != null;
  }

  bool get canContinueKyc {
    return nationalIdFront != null &&
        nationalIdBack != null &&
        selfieFile != null &&
        selfieVerified;
  }

  bool get canContinueProfessional {
    return licenseFile != null &&
        selectedServiceIds.isNotEmpty &&
        availability.any((slot) => slot.isAvailable);
  }

  bool get canSubmitWallet {
    return (bankName?.trim().isNotEmpty ?? false) &&
        (accountHolderName?.trim().isNotEmpty ?? false) &&
        (accountNumber?.trim().isNotEmpty ?? false) &&
        termsAccepted;
  }

  @override
  List<Object?> get props => [
    fullName,
    email,
    phone,
    businessName,
    profilePhoto?.path,
    latitude,
    longitude,
    locationAddress,
    locationError,
    isFetchingLocation,
    nationalIdFront?.path,
    nationalIdBack?.path,
    selfieFile?.path,
    selfieImagePath,
    selfieVerified,
    licenseFile?.path,
    yearsExperience,
    selectedServiceIds,
    servicePrices,
    services,
    availability,
    serviceRadiusKm,
    portfolioPhotos.map((file) => file.path).toList(),
    bankName,
    accountHolderName,
    accountNumber,
    addDebitCard,
    cardLast4,
    cardType,
    termsAccepted,
    currentStep,
    isLoading,
    uploadProgress,
    errorMessage,
    warningMessage,
    stylistId,
    rejectionReason,
    flowStatus,
  ];
}
