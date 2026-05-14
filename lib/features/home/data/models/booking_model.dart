import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.stylistId,
    super.clientId,
    required super.clientName,
    super.clientImageUrl,
    required super.serviceName,
    required super.durationMinutes,
    required super.status,
    required super.scheduledAt,
    required super.address,
    super.latitude,
    super.longitude,
    required super.totalAmount,
    required super.stylistEarnings,
    super.notes,
    super.cancellationReason,
    super.acceptDeadline,
    super.startedAt,
    super.completedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final user =
        _firstMap(json['client']) ??
        _firstMap(json['users']) ??
        _firstMap(json['customer']) ??
        _firstMap(json['customers']);
    final service =
        _firstMap(json['service']) ??
        _firstMap(json['services']) ??
        _firstMap(json['booking_services']);

    return BookingModel(
      id: (json['id'] ?? '').toString(),
      stylistId: (json['stylist_id'] ?? json['stylist'] ?? '').toString(),
      clientId: (json['client_id'] ?? json['customer'])?.toString(),
      clientName:
          (user?['name'] ??
                  '${user?['first_name'] ?? ''} ${user?['last_name'] ?? ''}'
                      .trim())
              .toString()
              .trim()
              .ifEmpty('Client'),
      clientImageUrl: (user?['profile_image_url'] ?? user?['image_url'])
          ?.toString(),
      serviceName: (service?['name'] ?? service?['service_name'] ?? 'Service')
          .toString(),
      durationMinutes:
          int.tryParse(
            (service?['duration_minutes'] ??
                    service?['duration_at_booking'] ??
                    json['duration_minutes'] ??
                    '0')
                .toString(),
          ) ??
          0,
      status: _statusFrom((json['status'] ?? 'pending').toString()),
      scheduledAt: _date(json['scheduled_at']) ?? DateTime.now(),
      address: (json['address_text'] ?? json['address'] ?? 'Client location')
          .toString(),
      latitude: double.tryParse((json['latitude'] ?? '').toString()),
      longitude: double.tryParse((json['longitude'] ?? '').toString()),
      totalAmount:
          double.tryParse((json['total_amount'] ?? '0').toString()) ?? 0,
      stylistEarnings:
          double.tryParse(
            (json['stylist_earnings'] ?? json['total_amount'] ?? '0')
                .toString(),
          ) ??
          0,
      notes: json['notes']?.toString(),
      cancellationReason: json['cancellation_reason']?.toString(),
      acceptDeadline: _date(json['accept_deadline']),
      startedAt: _date(json['started_at']),
      completedAt: _date(json['completed_at']),
    );
  }

  static BookingStatus _statusFrom(String value) {
    switch (value) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'in_progress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'missed':
        return BookingStatus.missed;
      default:
        return BookingStatus.pending;
    }
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  static Map<String, dynamic>? _firstMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is List && value.isNotEmpty && value.first is Map) {
      return Map<String, dynamic>.from(value.first as Map);
    }
    return null;
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
