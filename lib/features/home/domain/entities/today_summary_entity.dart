import 'package:equatable/equatable.dart';

class TodaySummaryEntity extends Equatable {
  final double earnings;
  final int bookingsCount;
  final double averageRating;

  const TodaySummaryEntity({
    required this.earnings,
    required this.bookingsCount,
    required this.averageRating,
  });

  factory TodaySummaryEntity.empty() {
    return const TodaySummaryEntity(
      earnings: 0,
      bookingsCount: 0,
      averageRating: 0,
    );
  }

  @override
  List<Object?> get props => [earnings, bookingsCount, averageRating];
}
