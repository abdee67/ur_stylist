import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ur_stylist/features/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/settings/domain/entities/stylist_profile_entity.dart';
import 'package:ur_stylist/features/settings/domain/usecases/settings_usecases.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final LoadSettingsProfile loadSettingsProfile;
  final SaveSettingsProfile saveSettingsProfile;
  final SaveSettingsAvailability saveSettingsAvailability;
  final AddSettingsPortfolioPhotos addSettingsPortfolioPhotos;
  final DeleteSettingsPortfolioPhoto deleteSettingsPortfolioPhoto;
  final SaveSettingsPayoutAccount saveSettingsPayoutAccount;
  final SaveSettingsPreferences saveSettingsPreferences;

  SettingsBloc(
    this.loadSettingsProfile,
    this.saveSettingsProfile,
    this.saveSettingsAvailability,
    this.addSettingsPortfolioPhotos,
    this.deleteSettingsPortfolioPhoto,
    this.saveSettingsPayoutAccount,
    this.saveSettingsPreferences,
  ) : super(SettingsState.initial()) {
    on<SettingsStarted>(_onStarted);
    on<SettingsProfileSaved>(_onProfileSaved);
    on<SettingsAvailabilitySaved>(_onAvailabilitySaved);
    on<SettingsPortfolioPhotosAdded>(_onPortfolioPhotosAdded);
    on<SettingsPortfolioPhotoDeleted>(_onPortfolioPhotoDeleted);
    on<SettingsPayoutSaved>(_onPayoutSaved);
    on<SettingsPreferenceToggled>(_onPreferenceToggled);
  }

  Future<void> _onStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final result = await loadSettingsProfile();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (profile) => emit(state.copyWith(isLoading: false, profile: profile)),
    );
  }

  Future<void> _onProfileSaved(
    SettingsProfileSaved event,
    Emitter<SettingsState> emit,
  ) async {
    await _action(
      emit,
      () => saveSettingsProfile(
        name: event.name,
        phone: event.phone,
        businessName: event.businessName,
        description: event.description,
        profilePhoto: event.profilePhoto,
        latitude: event.latitude,
        longitude: event.longitude,
        serviceRadiusKm: event.serviceRadiusKm,
      ),
      'Profile updated.',
    );
  }

  Future<void> _onAvailabilitySaved(
    SettingsAvailabilitySaved event,
    Emitter<SettingsState> emit,
  ) async {
    await _action(
      emit,
      () => saveSettingsAvailability(event.availability),
      'Availability updated.',
    );
  }

  Future<void> _onPortfolioPhotosAdded(
    SettingsPortfolioPhotosAdded event,
    Emitter<SettingsState> emit,
  ) async {
    await _action(
      emit,
      () => addSettingsPortfolioPhotos(event.photos),
      'Portfolio updated.',
    );
  }

  Future<void> _onPortfolioPhotoDeleted(
    SettingsPortfolioPhotoDeleted event,
    Emitter<SettingsState> emit,
  ) async {
    await _action(
      emit,
      () => deleteSettingsPortfolioPhoto(event.photo),
      'Photo deleted.',
    );
  }

  Future<void> _onPayoutSaved(
    SettingsPayoutSaved event,
    Emitter<SettingsState> emit,
  ) async {
    await _action(
      emit,
      () => saveSettingsPayoutAccount(
        bankName: event.bankName,
        accountHolderName: event.accountHolderName,
        accountNumber: event.accountNumber,
      ),
      'Your payout details have been updated.',
    );
  }

  Future<void> _onPreferenceToggled(
    SettingsPreferenceToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final preferences = Map<String, dynamic>.from(
      state.profile?.preferences ?? {},
    );
    preferences[event.keyName] = event.value;
    await _action(
      emit,
      () => saveSettingsPreferences(preferences),
      'Preferences updated.',
    );
  }

  Future<void> _action(
    Emitter<SettingsState> emit,
    Future<dynamic> Function() action,
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
        add(const SettingsStarted());
      },
    );
  }
}
