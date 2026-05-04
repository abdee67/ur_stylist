import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:ur_stylist/core/errors/failures.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    /* final Either<Failures, List<Stylist>> stylistsResult =
        await getStylists();
    final Either<Failures, List<ServiceCategories>> servicesResult =
        await getServices();
    final Either<Failures, List<Deal>> dealsResult = await getDeals();

    // Debug: Print results
    print('HomeBloc: Loading data...');
    stylistsResult.fold(
      (failure) => print('Stylist error: ${failure.message}'),
      (stylists) => print('Stylist loaded: ${stylists.length}'),
    );
    servicesResult.fold(
      (failure) => print('Services error: ${failure.message}'),
      (services) => print('Services loaded: ${services.length}'),
    );
    dealsResult.fold(
      (failure) => print('Deals error: ${failure.message}'),
      (deals) => print('Deals loaded: ${deals.length}'),
    );
    stylistsResult.fold(
      (failure) => emit(HomeLoadFailure(failure.message)),
      (stylists) {
        dealsResult.fold(
          (failure) => emit(HomeLoadFailure(failure.message)),
          (deals) => servicesResult.fold(
            (failure) => emit(HomeLoadFailure(failure.message)),
            (services) => emit(
              HomeLoadSuccess(
                stylists: stylists,
                deals: deals,
                services: services,
              ),
            ),
          ),
        );
      },
    );*/
  }
}
