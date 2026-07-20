// Extract business logic into a separate service class
import 'package:ur_stylist/core/constants/app_constants.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';

class CashPaymentVerificationService {
  bool matchesCashQrPayload(String rawValue, BookingEntity booking) {
    final uri = Uri.tryParse(rawValue);
    if (uri == null ||
        uri.scheme != AppConstants.qrScheme ||
        uri.host != AppConstants.qrHost) {
      return false;
    }

    final bookingId = uri.queryParameters['booking_id'];
    final customerId = uri.queryParameters['customer_id'];
    final stylistId = uri.queryParameters['stylist_id'];

    return bookingId == booking.id &&
        (customerId == null || customerId == booking.clientId) &&
        (stylistId == null || stylistId == booking.stylistId);
  }

  /// Must produce the exact same code as `_cashOtp` in the customer app
  /// (payment_methods_screen.dart), which displays the OTP to the client.
  /// Both sides derive it from the same booking fields with the same
  /// 31-multiplier hash — do not change one without the other.
  String generateCashOtp(BookingEntity booking) {
    final source =
        '${booking.id}:${booking.clientId ?? ''}:${booking.stylistId}';
    final hash = source.codeUnits.fold<int>(
      0,
      (value, codeUnit) =>
          (value * AppConstants.hashMultiplier + codeUnit) &
          AppConstants.hashMask,
    );
    return (AppConstants.minOtpValue + hash % AppConstants.maxOtpRange)
        .toString();
  }
}