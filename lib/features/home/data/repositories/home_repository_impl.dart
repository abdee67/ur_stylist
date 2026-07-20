import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
  Future<Either<Failures, void>> confirmCashPayment(String bookingId) =>
      _guard(() => remoteDataSource.confirmCashPayment(bookingId));

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
    } on Failures catch (failure) {
      // Edge Function / API errors already carry a readable message —
      // pass them through instead of wrapping ("Instance of 'Failures'").
      if (kDebugMode) {
        developer.log('something like this happened: ${failure.message}');
      }
      return Left(failure);
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        developer.log('something like this happened: ${e.message}');
      }
      return Left(
        Failures(
          message: 'Something went wrong. Please try again. ${e.message}',
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log('something like this happened: $e');
      }
      return Left(
        Failures(message: 'Something went wrong. Please try again. $e'),
      );
    }
  }
}
