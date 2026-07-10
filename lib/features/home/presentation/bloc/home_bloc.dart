import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';
import 'package:ur_stylist/features/home/domain/entities/today_summary_entity.dart';
import 'package:ur_stylist/features/home/domain/repositories/home_repository.dart';
import 'package:ur_stylist/features/home/domain/usecases/booking_actions.dart';
import 'package:ur_stylist/features/home/domain/usecases/load_home_dashboard.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final LoadHomeDashboard loadHomeDashboard;
  final AcceptBooking acceptBooking;
  final DeclineBooking declineBooking;
  final StartBooking startBooking;
  final CompleteBooking completeBooking;
  final ConfirmCashPayment confirmCashPayment;
  final HomeRepository homeRepository;
  RealtimeChannel? _bookingsChannel;

  HomeBloc(
    this.loadHomeDashboard,
    this.acceptBooking,
    this.declineBooking,
    this.startBooking,
    this.completeBooking,
    this.confirmCashPayment,
    this.homeRepository,
  ) : super(HomeState.initial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<AcceptBookingRequested>(_onAcceptBooking);
    on<DeclineBookingRequested>(_onDeclineBooking);
    on<StartBookingRequested>(_onStartBooking);
    on<CompleteBookingRequested>(_onCompleteBooking);
    on<ConfirmCashPaymentRequested>(_onConfirmCashPayment);
    on<HomeHistoryFilterChanged>((event, emit) {
      emit(state.copyWith(historyFilter: event.filter, clearMessages: true));
    });
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    await _load(emit, subscribe: true);
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    await _load(emit, subscribe: false);
  }

  Future<void> _load(Emitter<HomeState> emit, {required bool subscribe}) async {
    final result = await loadHomeDashboard();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (data) {
        emit(
          state.copyWith(
            isLoading: false,
            stylistId: data.stylistId,
            bookings: data.bookings,
            summary: data.summary,
            pendingCount: data.pendingCount,
          ),
        );
        if (subscribe) {
          _bookingsChannel?.unsubscribe();
          _bookingsChannel = homeRepository.subscribeToBookings(
            data.stylistId,
            () => add(const RefreshHomeData()),
          );
        }
      },
    );
  }

  Future<void> _onAcceptBooking(
    AcceptBookingRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _runAction(
      emit,
      () => acceptBooking(event.bookingId),
      'Booking accepted.',
    );
  }

  Future<void> _onDeclineBooking(
    DeclineBookingRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _runAction(
      emit,
      () => declineBooking(event.bookingId, event.reason),
      'Booking declined.',
    );
  }

  Future<void> _onStartBooking(
    StartBookingRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _runAction(
      emit,
      () => startBooking(event.bookingId),
      'Service started.',
    );
  }

  Future<void> _onCompleteBooking(
    CompleteBookingRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _runAction(
      emit,
      () => completeBooking(event.bookingId),
      'Service completed.',
    );
  }

  Future<void> _onConfirmCashPayment(
    ConfirmCashPaymentRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _runAction(
      emit,
      () => confirmCashPayment(event.bookingId),
      'Cash payment confirmed. Commission was debited.',
    );
  }

  Future<void> _runAction(
    Emitter<HomeState> emit,
    Future<Either<Failures, void>> Function() action,
    String message,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearMessages: true));
    final result = await action();
    result.fold(
      (failure) => emit(
        state.copyWith(isActionLoading: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isActionLoading: false, successMessage: message));
        add(const RefreshHomeData());
      },
    );
  }

  @override
  Future<void> close() {
    _bookingsChannel?.unsubscribe();
    return super.close();
  }
}
