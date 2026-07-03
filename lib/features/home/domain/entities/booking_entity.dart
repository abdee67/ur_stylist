import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  missed,
}

class BookingEntity extends Equatable {
  final String id;
  final String stylistId;
  final String? clientId;
  final String clientName;
  final String? clientImageUrl;
  final String serviceName;
  final int durationMinutes;
  final BookingStatus status;
  final DateTime scheduledAt;
  final String address;
  final double? latitude;
  final double? longitude;
  final double totalAmount;
  final double stylistEarnings;
  final String? notes;
  final String? cancellationReason;
  final DateTime? acceptDeadline;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const BookingEntity({
    required this.id,
    required this.stylistId,
    this.clientId,
    required this.clientName,
    this.clientImageUrl,
    required this.serviceName,
    required this.durationMinutes,
    required this.status,
    required this.scheduledAt,
    required this.address,
    this.latitude,
    this.longitude,
    required this.totalAmount,
    required this.stylistEarnings,
    this.notes,
    this.cancellationReason,
    this.acceptDeadline,
    this.startedAt,
    this.completedAt,
  });

  bool get isExpired {
    final deadline = acceptDeadline;
    return status == BookingStatus.pending &&
        deadline != null &&
        deadline.isBefore(DateTime.now());
  }

  //cear address(Precise Location)
  String get cleanAddress {
    return address
        .replaceAll(RegExp(r'\d+'), '') // remove numbers
        .replaceAll(RegExp(r'[^a-zA-Z\s]'), '') // remove symbols
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' '); // replace multiple spaces with one
  }

  @override
  List<Object?> get props => [
    id,
    stylistId,
    clientId,
    clientName,
    clientImageUrl,
    serviceName,
    durationMinutes,
    status,
    scheduledAt,
    address,
    latitude,
    longitude,
    totalAmount,
    stylistEarnings,
    notes,
    cancellationReason,
    acceptDeadline,
    startedAt,
    completedAt,
  ];
}
