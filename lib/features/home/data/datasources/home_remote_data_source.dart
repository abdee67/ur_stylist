import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';
import 'package:ur_stylist/features/home/domain/entities/today_summary_entity.dart';

abstract class HomeRemoteDataSource {
  Future<String> getStylistId();
  Future<List<BookingEntity>> getBookings();
  Future<TodaySummaryEntity> getTodaySummary();
  Future<int> getPendingCount();
  Future<void> acceptBooking(String bookingId);
  Future<void> declineBooking(String bookingId, String? reason);
  Future<void> startBooking(String bookingId);
  Future<void> completeBooking(String bookingId);
  Future<void> confirmCashPayment(String bookingId);
  RealtimeChannel subscribeToBookings(String stylistId, VoidCallback onChange);
}

typedef VoidCallback = void Function();
