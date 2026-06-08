part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final StylistProfileEntity? profile;
  final bool signedOut;
  final String? errorMessage;
  final String? successMessage;

  const SettingsState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.profile,
    this.signedOut = false,
    this.errorMessage,
    this.successMessage,
  });

  factory SettingsState.initial() => const SettingsState();

  SettingsState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    StylistProfileEntity? profile,
    bool? signedOut,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      profile: profile ?? this.profile,
      signedOut: signedOut ?? this.signedOut,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isActionLoading,
    profile,
    signedOut,
    errorMessage,
    successMessage,
  ];
}
