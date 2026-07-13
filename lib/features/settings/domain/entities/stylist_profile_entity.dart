import 'package:equatable/equatable.dart';
import 'package:ur_stylist/features/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/wallet/domain/entities/payout_account_entity.dart';

class PortfolioPhotoEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String? caption;

  const PortfolioPhotoEntity({
    required this.id,
    required this.imageUrl,
    this.caption,
  });

  @override
  List<Object?> get props => [id, imageUrl, caption];
}

class StylistProfileEntity extends Equatable {
  final String stylistId;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String businessName;
  final String? description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final int serviceRadiusKm;
  final String onboardingStatus;
  final String? rejectionReason;
  final Map<String, dynamic> preferences;
  final List<PortfolioPhotoEntity> portfolio;
  final List<AvailabilitySlot> availability;
  final PayoutAccountEntity? payoutAccount;

  const StylistProfileEntity({
    required this.stylistId,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.businessName,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
    required this.serviceRadiusKm,
    required this.onboardingStatus,
    this.rejectionReason,
    required this.preferences,
    required this.portfolio,
    required this.availability,
    this.payoutAccount,
  });

  @override
  List<Object?> get props => [
    stylistId,
    userId,
    name,
    email,
    phone,
    businessName,
    description,
    imageUrl,
    latitude,
    longitude,
    serviceRadiusKm,
    onboardingStatus,
    rejectionReason,
    preferences,
    portfolio,
    availability,
    payoutAccount,
  ];
}
