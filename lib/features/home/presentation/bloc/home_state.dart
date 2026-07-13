part of 'home_bloc.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final String? stylistId;
  final List<BookingEntity> bookings;
  final TodaySummaryEntity summary;
  final int pendingCount;
  final String historyFilter;
  final String? errorMessage;
  final String? successMessage;

  const HomeState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.stylistId,
    this.bookings = const [],
    required this.summary,
    this.pendingCount = 0,
    this.historyFilter = 'all',
    this.errorMessage,
    this.successMessage,
  });

  factory HomeState.initial() {
    return HomeState(summary: TodaySummaryEntity.empty());
  }

  HomeState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    String? stylistId,
    List<BookingEntity>? bookings,
    TodaySummaryEntity? summary,
    int? pendingCount,
    String? historyFilter,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      stylistId: stylistId ?? this.stylistId,
      bookings: bookings ?? this.bookings,
      summary: summary ?? this.summary,
      pendingCount: pendingCount ?? this.pendingCount,
      historyFilter: historyFilter ?? this.historyFilter,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  List<BookingEntity> get pendingBookings => bookings
      .where((booking) => booking.status == BookingStatus.pending)
      .toList();

  List<BookingEntity> get activeBookings =>
      bookings
          .where(
            (booking) =>
                booking.status == BookingStatus.confirmed ||
                booking.status == BookingStatus.inProgress,
          )
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  /// Service finished but the payment is not settled yet. These stay visible
  /// and actionable (cash confirmation) instead of dropping into history.
  List<BookingEntity> get awaitingPaymentBookings =>
      bookings.where((booking) => booking.isAwaitingPayment).toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  List<BookingEntity> get historyBookings {
    final items = bookings
        .where(
          (booking) =>
              (booking.status == BookingStatus.completed &&
                  !booking.isAwaitingPayment) ||
              booking.status == BookingStatus.cancelled ||
              booking.status == BookingStatus.missed,
        )
        .where((booking) {
          if (historyFilter == 'completed') {
            return booking.status == BookingStatus.completed;
          }
          if (historyFilter == 'cancelled') {
            return booking.status == BookingStatus.cancelled ||
                booking.status == BookingStatus.missed;
          }
          return true;
        })
        .toList();
    items.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return items;
  }

  @override
  List<Object?> get props => [
    isLoading,
    isActionLoading,
    stylistId,
    bookings,
    summary,
    pendingCount,
    historyFilter,
    errorMessage,
    successMessage,
  ];
}
