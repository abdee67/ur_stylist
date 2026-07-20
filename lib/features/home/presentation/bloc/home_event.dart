part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}

class AcceptBookingRequested extends HomeEvent {
  final String bookingId;
  const AcceptBookingRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class DeclineBookingRequested extends HomeEvent {
  final String bookingId;
  final String? reason;
  const DeclineBookingRequested(this.bookingId, this.reason);
  @override
  List<Object?> get props => [bookingId, reason];
}

class StartBookingRequested extends HomeEvent {
  final String bookingId;
  const StartBookingRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class CompleteBookingRequested extends HomeEvent {
  final String bookingId;
  const CompleteBookingRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class ConfirmCashPaymentRequested extends HomeEvent {
  final String bookingId;
  const ConfirmCashPaymentRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class HomeHistoryFilterChanged extends HomeEvent {
  final String filter;
  const HomeHistoryFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}
