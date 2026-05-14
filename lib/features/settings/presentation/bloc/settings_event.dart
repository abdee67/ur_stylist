part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

class SettingsProfileSaved extends SettingsEvent {
  final String name;
  final String phone;
  final String businessName;
  final String? description;
  final File? profilePhoto;
  final double? latitude;
  final double? longitude;
  final int serviceRadiusKm;

  const SettingsProfileSaved({
    required this.name,
    required this.phone,
    required this.businessName,
    this.description,
    this.profilePhoto,
    this.latitude,
    this.longitude,
    required this.serviceRadiusKm,
  });
}

class SettingsAvailabilitySaved extends SettingsEvent {
  final List<AvailabilitySlot> availability;
  const SettingsAvailabilitySaved(this.availability);
}

class SettingsPortfolioPhotosAdded extends SettingsEvent {
  final List<File> photos;
  const SettingsPortfolioPhotosAdded(this.photos);
}

class SettingsPortfolioPhotoDeleted extends SettingsEvent {
  final PortfolioPhotoEntity photo;
  const SettingsPortfolioPhotoDeleted(this.photo);
}

class SettingsPayoutSaved extends SettingsEvent {
  final String bankName;
  final String accountHolderName;
  final String accountNumber;
  const SettingsPayoutSaved({
    required this.bankName,
    required this.accountHolderName,
    required this.accountNumber,
  });
}

class SettingsPreferenceToggled extends SettingsEvent {
  final String keyName;
  final bool value;
  const SettingsPreferenceToggled(this.keyName, this.value);
}

class SettingsSignOutRequested extends SettingsEvent {
  const SettingsSignOutRequested();
}

class SettingsDeactivateRequested extends SettingsEvent {
  const SettingsDeactivateRequested();
}
