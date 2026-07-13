import 'package:flutter/material.dart';
import 'package:ur_stylist/features/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/settings/domain/entities/stylist_profile_entity.dart';
import 'package:ur_stylist/features/wallet/data/models/payout_account_model.dart';

class StylistProfileModel extends StylistProfileEntity {
  const StylistProfileModel({
    required super.stylistId,
    required super.userId,
    required super.name,
    required super.email,
    required super.phone,
    required super.businessName,
    super.description,
    super.imageUrl,
    super.latitude,
    super.longitude,
    required super.serviceRadiusKm,
    required super.onboardingStatus,
    super.rejectionReason,
    required super.preferences,
    required super.portfolio,
    required super.availability,
    super.payoutAccount,
  });

  factory StylistProfileModel.fromParts({
    required Map<String, dynamic> stylist,
    required Map<String, dynamic> user,
    required List<dynamic> portfolio,
    required List<dynamic> availability,
    Map<String, dynamic>? payoutAccount,
  }) {
    return StylistProfileModel(
      stylistId: stylist['id'].toString(),
      userId: stylist['user_id'].toString(),
      name: (user['name'] ?? '').toString(),
      email: (user['email'] ?? '').toString(),
      phone: (user['phone'] ?? '').toString(),
      businessName: (stylist['business_name'] ?? '').toString(),
      description: stylist['description']?.toString(),
      imageUrl: stylist['image_url']?.toString(),
      latitude: double.tryParse((stylist['latitude'] ?? '').toString()),
      longitude: double.tryParse((stylist['longitude'] ?? '').toString()),
      serviceRadiusKm:
          int.tryParse((stylist['service_radius_km'] ?? '10').toString()) ?? 10,
      onboardingStatus: (stylist['onboarding_status'] ?? 'approved').toString(),
      rejectionReason: stylist['rejection_reason']?.toString(),
      preferences: stylist['preferences'] is Map
          ? Map<String, dynamic>.from(stylist['preferences'])
          : const {},
      portfolio: portfolio
          .map(
            (item) => PortfolioPhotoEntity(
              id: item['id'].toString(),
              imageUrl: (item['image_url'] ?? '').toString(),
              caption: item['caption']?.toString(),
            ),
          )
          .toList(),
      availability: availability.map((item) {
        return AvailabilitySlot(
          dayOfWeek: (item['day_of_week'] ?? '').toString(),
          startTime: _time(
            item['start_time']?.toString(),
            const TimeOfDay(hour: 9, minute: 0),
          ),
          endTime: _time(
            item['end_time']?.toString(),
            const TimeOfDay(hour: 18, minute: 0),
          ),
          isAvailable: item['is_available'] != false,
        );
      }).toList(),
      payoutAccount: payoutAccount == null
          ? null
          : PayoutAccountModel.fromJson(payoutAccount),
    );
  }

  static TimeOfDay _time(String? value, TimeOfDay fallback) {
    if (value == null) return fallback;
    final parts = value.split(':');
    if (parts.length < 2) return fallback;
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? fallback.hour,
      minute: int.tryParse(parts[1]) ?? fallback.minute,
    );
  }
}
