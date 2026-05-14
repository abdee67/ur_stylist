import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/home/data/datasources/home_remote_data_source.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';
import 'package:ur_stylist/features/home/domain/entities/today_summary_entity.dart';
import 'package:ur_stylist/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failures, String>> getStylistId() =>
      _guard(remoteDataSource.getStylistId);

  @override
  Future<Either<Failures, List<BookingEntity>>> getBookings() =>
      _guard(remoteDataSource.getBookings);

  @override
  Future<Either<Failures, TodaySummaryEntity>> getTodaySummary() =>
      _guard(remoteDataSource.getTodaySummary);

  @override
  Future<Either<Failures, int>> getPendingCount() =>
      _guard(remoteDataSource.getPendingCount);

  @override
  Future<Either<Failures, void>> acceptBooking(String bookingId) =>
      _guard(() => remoteDataSource.acceptBooking(bookingId));

  @override
  Future<Either<Failures, void>> declineBooking(
    String bookingId,
    String? reason,
  ) => _guard(() => remoteDataSource.declineBooking(bookingId, reason));

  @override
  Future<Either<Failures, void>> startBooking(String bookingId) =>
      _guard(() => remoteDataSource.startBooking(bookingId));

  @override
  Future<Either<Failures, void>> completeBooking(String bookingId) =>
      _guard(() => remoteDataSource.completeBooking(bookingId));

  @override
  RealtimeChannel subscribeToBookings(
    String stylistId,
    void Function() onChange,
  ) {
    return remoteDataSource.subscribeToBookings(stylistId, onChange);
  }

  Future<Either<Failures, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on PostgrestException catch (e) {
      return Left(Failures(message: _mapError(e.code)));
    } catch (_) {
      return Left(Failures(message: 'Something went wrong. Please try again.'));
    }
  }

  String _mapError(String? code) => switch (code) {
    '23505' => 'This record already exists',
    '42501' => "You don't have permission to do that",
    _ => 'Something went wrong. Please try again.',
  };
}
