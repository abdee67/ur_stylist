import 'package:ur_stylist/api/api_service.dart';
import 'package:ur_stylist/core/errors/failures.dart';

class CashPaymentApiService extends ApiService {
  CashPaymentApiService({super.client});

  Future<void> receiveCashPayment(String bookingId) async {
    _requireValue(bookingId, 'Booking id is required.');

    await invokeFunction(
      'receive-cash-payment',
      body: <String, dynamic>{'booking_id': bookingId},
    );
  }

  void _requireValue(String value, String message) {
    if (value.trim().isEmpty) {
      throw Failures(message: message);
    }
  }
}
