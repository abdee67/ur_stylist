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
    final bookingServices = _maps(json['booking_services']);
    final service =
        _firstMap(json['service']) ??
        _firstMap(json['services']) ??
        _firstMap(
          bookingServices.isEmpty ? null : bookingServices.first['service'],
        ) ??
        _firstMap(bookingServices.isEmpty ? null : bookingServices.first);
    final customerAddress = _firstMap(json['customer_address']);

    return BookingModel(
      id: (json['id'] ?? '').toString(),
      stylistId: (json['stylist'] ?? json['stylist_id'] ?? '').toString(),
      clientId: (json['customer'] ?? json['client_id'])?.toString(),
      clientName:
          (user?['name'] ??
                  '${user?['first_name'] ?? ''} ${user?['last_name'] ?? ''}'
                      .trim())
              .toString()
              .trim()
              .ifEmpty('Client'),
      clientImageUrl: (user?['profile_image_url'] ?? user?['image_url'])
          ?.toString(),
      serviceName: _serviceName(bookingServices, service),
      durationMinutes: _durationMinutes(bookingServices, service, json),
      status: _statusFrom((json['status'] ?? 'pending').toString()),
      scheduledAt: _date(json['scheduled_at']) ?? DateTime.now(),
      address: _addressText(customerAddress, json),
      latitude: double.tryParse(
        (customerAddress?['latitude'] ?? json['latitude'] ?? '').toString(),
      ),
      longitude: double.tryParse(
        (customerAddress?['longitude'] ?? json['longitude'] ?? '').toString(),
      ),
      totalAmount:
          double.tryParse((json['total_amount'] ?? '0').toString()) ?? 0,
      stylistEarnings:
          double.tryParse(
            (json['stylist_earning'] ??
                    json['stylist_earnings'] ??
                    json['total_amount'] ??
                    '0')
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

  static List<Map<String, dynamic>> _maps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static String _serviceName(
    List<Map<String, dynamic>> bookingServices,
    Map<String, dynamic>? fallback,
  ) {
    final names = bookingServices
        .map((item) {
          final service = _firstMap(item['service']);
          return (item['service_name'] ?? service?['name'])?.toString();
        })
        .where((name) => name != null && name.trim().isNotEmpty)
        .cast<String>()
        .toList();
    if (names.isNotEmpty) return names.join(', ');
    return (fallback?['name'] ?? fallback?['service_name'] ?? 'Service')
        .toString();
  }

  static int _durationMinutes(
    List<Map<String, dynamic>> bookingServices,
    Map<String, dynamic>? fallback,
    Map<String, dynamic> booking,
  ) {
    var total = 0;
    for (final item in bookingServices) {
      total +=
          int.tryParse((item['duration_at_booking'] ?? '0').toString()) ?? 0;
    }
    if (total > 0) return total;
    return int.tryParse(
          (fallback?['duration_minutes'] ??
                  fallback?['duration_at_booking'] ??
                  booking['duration_minutes'] ??
                  '0')
              .toString(),
        ) ??
        0;
  }

  static String _addressText(
    Map<String, dynamic>? customerAddress,
    Map<String, dynamic> booking,
  ) {
    if (customerAddress != null) {
      final parts =
          [
                customerAddress['address_line1'],
                customerAddress['address_line2'],
                customerAddress['city'],
                customerAddress['state'],
              ]
              .where(
                (part) => part != null && part.toString().trim().isNotEmpty,
              )
              .map((part) => part.toString().trim())
              .toList();
      if (parts.isNotEmpty) return parts.join(', ');
    }
    return (booking['address_text'] ?? booking['address'] ?? 'Client location')
        .toString();
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
