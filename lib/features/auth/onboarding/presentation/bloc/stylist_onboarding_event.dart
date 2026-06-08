import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/service_entity.dart';

abstract class StylistOnboardingEvent extends Equatable {
  const StylistOnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingStarted extends StylistOnboardingEvent {
  const OnboardingStarted();
}

class OnboardingBackPressed extends StylistOnboardingEvent {
  const OnboardingBackPressed();
}

class BasicInfoChanged extends StylistOnboardingEvent {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? businessName;

  const BasicInfoChanged({
    this.fullName,
    this.email,
    this.phone,
    this.businessName,
  });

  @override
  List<Object?> get props => [fullName, email, phone, businessName];
}

class ProfilePhotoChanged extends StylistOnboardingEvent {
  final File photo;

  const ProfilePhotoChanged(this.photo);

  @override
  List<Object?> get props => [photo.path];
}

class CurrentLocationRequested extends StylistOnboardingEvent {
  const CurrentLocationRequested();
}

class BasicInfoSubmitted extends StylistOnboardingEvent {
  const BasicInfoSubmitted();
}

class OtpSubmitted extends StylistOnboardingEvent {
  final String otp;

  const OtpSubmitted(this.otp);

  @override
  List<Object?> get props => [otp];
}

class OtpResent extends StylistOnboardingEvent {
  const OtpResent();
}

class KycFileChanged extends StylistOnboardingEvent {
  final String type;
  final File file;

  const KycFileChanged({required this.type, required this.file});

  @override
  List<Object?> get props => [type, file.path];
}

class KycSubmitted extends StylistOnboardingEvent {
  const KycSubmitted();
}

class ServicesRequested extends StylistOnboardingEvent {
  const ServicesRequested();
}

class LicenseFileChanged extends StylistOnboardingEvent {
  final File file;

  const LicenseFileChanged(this.file);

  @override
  List<Object?> get props => [file.path];
}

class YearsExperienceChanged extends StylistOnboardingEvent {
  final int years;

  const YearsExperienceChanged(this.years);

  @override
  List<Object?> get props => [years];
}

class ServiceSelectionToggled extends StylistOnboardingEvent {
  final ServiceEntity service;
  final double? price;

  const ServiceSelectionToggled({required this.service, this.price});

  @override
  List<Object?> get props => [service, price];
}

class AvailabilityUpdated extends StylistOnboardingEvent {
  final AvailabilitySlot slot;

  const AvailabilityUpdated(this.slot);

  @override
  List<Object?> get props => [slot];
}

class ServiceRadiusChanged extends StylistOnboardingEvent {
  final int radiusKm;

  const ServiceRadiusChanged(this.radiusKm);

  @override
  List<Object?> get props => [radiusKm];
}

class PortfolioPhotoAdded extends StylistOnboardingEvent {
  final File photo;

  const PortfolioPhotoAdded(this.photo);

  @override
  List<Object?> get props => [photo.path];
}

class PortfolioPhotoRemoved extends StylistOnboardingEvent {
  final int index;

  const PortfolioPhotoRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class ProfessionalDetailsSubmitted extends StylistOnboardingEvent {
  const ProfessionalDetailsSubmitted();
}

class WalletInfoChanged extends StylistOnboardingEvent {
  final String? bankName;
  final String? accountHolderName;
  final String? accountNumber;
  final bool? termsAccepted;
  final bool? addDebitCard;
  final String? cardNumber;

  const WalletInfoChanged({
    this.bankName,
    this.accountHolderName,
    this.accountNumber,
    this.termsAccepted,
    this.addDebitCard,
    this.cardNumber,
  });

  @override
  List<Object?> get props => [
    bankName,
    accountHolderName,
    accountNumber,
    termsAccepted,
    addDebitCard,
    cardNumber,
  ];
}

class WalletSubmitted extends StylistOnboardingEvent {
  const WalletSubmitted();
}

class PasswordSubmitted extends StylistOnboardingEvent {
  final String password;
  final String confirmPassword;

  const PasswordSubmitted({
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [password, confirmPassword];
}

class SubmittedSignOutRequested extends StylistOnboardingEvent {
  const SubmittedSignOutRequested();
}

class RejectedResubmitRequested extends StylistOnboardingEvent {
  const RejectedResubmitRequested();
}

class OnboardingMessageCleared extends StylistOnboardingEvent {
  const OnboardingMessageCleared();
}
