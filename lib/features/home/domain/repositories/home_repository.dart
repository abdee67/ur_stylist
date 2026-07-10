import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';
import 'package:ur_stylist/features/home/domain/entities/today_summary_entity.dart';

abstract class HomeRepository {
  Future<Either<Failures, String>> getStylistId();
  Future<Either<Failures, List<BookingEntity>>> getBookings();
  Future<Either<Failures, TodaySummaryEntity>> getTodaySummary();
  Future<Either<Failures, int>> getPendingCount();
  Future<Either<Failures, void>> acceptBooking(String bookingId);
  Future<Either<Failures, void>> declineBooking(
    String bookingId,
    String? reason,
  );
  Future<Either<Failures, void>> startBooking(String bookingId);
  Future<Either<Failures, void>> completeBooking(String bookingId);
  Future<Either<Failures, void>> confirmCashPayment(String bookingId);
  RealtimeChannel subscribeToBookings(
    String stylistId,
    void Function() onChange,
  );
}
