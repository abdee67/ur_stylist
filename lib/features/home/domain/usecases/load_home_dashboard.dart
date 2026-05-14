import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';
import 'package:ur_stylist/features/home/domain/entities/today_summary_entity.dart';
import 'package:ur_stylist/features/home/domain/repositories/home_repository.dart';

class HomeDashboardData {
  final String stylistId;
  final List<BookingEntity> bookings;
  final TodaySummaryEntity summary;
  final int pendingCount;

  const HomeDashboardData({
    required this.stylistId,
    required this.bookings,
    required this.summary,
    required this.pendingCount,
  });
}

class LoadHomeDashboard {
  final HomeRepository repository;

  LoadHomeDashboard(this.repository);

  Future<Either<Failures, HomeDashboardData>> call() async {
    final stylist = await repository.getStylistId();
    if (stylist.isLeft()) {
      return Left(
        stylist.swap().getOrElse(
          () => Failures(message: 'Something went wrong.'),
        ),
      );
    }
    final bookings = await repository.getBookings();
    if (bookings.isLeft()) {
      return Left(
        bookings.swap().getOrElse(
          () => Failures(message: 'Something went wrong.'),
        ),
      );
    }
    final summary = await repository.getTodaySummary();
    if (summary.isLeft()) {
      return Left(
        summary.swap().getOrElse(
          () => Failures(message: 'Something went wrong.'),
        ),
      );
    }
    final count = await repository.getPendingCount();
    if (count.isLeft()) {
      return Left(
        count.swap().getOrElse(
          () => Failures(message: 'Something went wrong.'),
        ),
      );
    }

    return Right(
      HomeDashboardData(
        stylistId: stylist.getOrElse(() => ''),
        bookings: bookings.getOrElse(() => const []),
        summary: summary.getOrElse(TodaySummaryEntity.empty),
        pendingCount: count.getOrElse(() => 0),
      ),
    );
  }
}
