import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  missed,
}

enum PaymentStatus {
  pending,
  paid,
  refunded,
  failed,
  partialRefunded,
  pendingVerification,
  disputed,
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
  final String paymentMethod;
  final PaymentStatus paymentStatus;
  final double? paidAmount;
  final DateTime? cashReceivedAt;

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
    this.paymentMethod = '',
    this.paymentStatus = PaymentStatus.pending,
    this.paidAmount,
    this.cashReceivedAt,
  });

  bool get isExpired {
    final deadline = acceptDeadline;
    return status == BookingStatus.pending &&
        deadline != null &&
        deadline.isBefore(DateTime.now());
  }

  bool get isPaid => paymentStatus == PaymentStatus.paid;

  bool get isCash => paymentMethod.toLowerCase() == 'cash';

  /// Service is finished but the money has not settled yet, so the booking
  /// still needs the stylist's attention and must not disappear into history.
  bool get isAwaitingPayment =>
      status == BookingStatus.completed &&
      (paymentStatus == PaymentStatus.pending ||
          paymentStatus == PaymentStatus.failed);

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
    paymentMethod,
    paymentStatus,
    paidAmount,
    cashReceivedAt,
  ];
}
