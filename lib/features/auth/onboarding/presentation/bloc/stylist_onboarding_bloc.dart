import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/onboarding_flow_status.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/onboarding_state_entity.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/get_active_services.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/load_existing_onboarding.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/resend_stylist_otp.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/save_basic_info.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/save_kyc.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/save_professional_details.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/sign_out_stylist.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/submit_wallet.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/verify_stylist_otp.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_event.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_state.dart';

class StylistOnboardingBloc
    extends Bloc<StylistOnboardingEvent, StylistOnboardingState> {
  final LoadExistingOnboarding loadExistingOnboarding;
  final SaveBasicInfo saveBasicInfo;
  final VerifyStylistOtp verifyStylistOtp;
  final ResendStylistOtp resendStylistOtp;
  final SaveKyc saveKyc;
  final GetActiveServices getActiveServices;
  final SaveProfessionalDetails saveProfessionalDetails;
  final SubmitWallet submitWallet;
  final SignOutStylist signOutStylist;

  StylistOnboardingBloc(
    this.loadExistingOnboarding,
    this.saveBasicInfo,
    this.verifyStylistOtp,
    this.resendStylistOtp,
    this.saveKyc,
    this.getActiveServices,
    this.saveProfessionalDetails,
    this.submitWallet,
    this.signOutStylist,
  ) : super(StylistOnboardingState.initial()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingBackPressed>(_onBackPressed);
    on<BasicInfoChanged>(_onBasicInfoChanged);
    on<ProfilePhotoChanged>((event, emit) {
      emit(
        StylistOnboardingState(state.data.copyWith(profilePhoto: event.photo)),
      );
    });
    on<CurrentLocationRequested>(_onLocationRequested);
    on<BasicInfoSubmitted>(_onBasicInfoSubmitted);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResent>(_onOtpResent);
    on<KycFileChanged>(_onKycFileChanged);
    on<KycSubmitted>(_onKycSubmitted);
    on<ServicesRequested>(_onServicesRequested);
    on<LicenseFileChanged>((event, emit) {
      emit(
        StylistOnboardingState(state.data.copyWith(licenseFile: event.file)),
      );
    });
    on<YearsExperienceChanged>((event, emit) {
      emit(
        StylistOnboardingState(
          state.data.copyWith(yearsExperience: event.years),
        ),
      );
    });
    on<ServiceSelectionToggled>(_onServiceSelectionToggled);
    on<AvailabilityUpdated>(_onAvailabilityUpdated);
    on<ServiceRadiusChanged>((event, emit) {
      emit(
        StylistOnboardingState(
          state.data.copyWith(serviceRadiusKm: event.radiusKm),
        ),
      );
    });
    on<PortfolioPhotoAdded>((event, emit) {
      emit(
        StylistOnboardingState(
          state.data.copyWith(
            portfolioPhotos: [...state.data.portfolioPhotos, event.photo],
          ),
        ),
      );
    });
    on<PortfolioPhotoRemoved>((event, emit) {
      final photos = [...state.data.portfolioPhotos];
      if (event.index >= 0 && event.index < photos.length) {
        photos.removeAt(event.index);
      }
      emit(
        StylistOnboardingState(state.data.copyWith(portfolioPhotos: photos)),
      );
    });
    on<ProfessionalDetailsSubmitted>(_onProfessionalSubmitted);
    on<WalletInfoChanged>(_onWalletChanged);
    on<WalletSubmitted>(_onWalletSubmitted);
    on<SubmittedSignOutRequested>(_onSignOutRequested);
    on<RejectedResubmitRequested>((event, emit) {
      emit(
        StylistOnboardingState(
          state.data.copyWith(
            flowStatus: OnboardingFlowStatus.inProgress,
            currentStep: 2,
            clearError: true,
          ),
        ),
      );
    });
    on<OnboardingMessageCleared>((event, emit) {
      emit(
        StylistOnboardingState(
          state.data.copyWith(clearError: true, clearWarning: true),
        ),
      );
    });
  }

  Future<void> _onStarted(
    OnboardingStarted event,
    Emitter<StylistOnboardingState> emit,
  ) async {
    emit(
      StylistOnboardingState(
        state.data.copyWith(isLoading: true, clearError: true),
      ),
    );
    final result = await loadExistingOnboarding();
    result.fold(
      (failure) => emit(
        StylistOnboardingState(
          state.data.copyWith(isLoading: false, errorMessage: failure.message),
        ),
      ),
      (data) {
        emit(StylistOnboardingState(data.copyWith(isLoading: false)));
        if (data.flowStatus == OnboardingFlowStatus.inProgress &&
            data.currentStep >= 3) {
          add(const ServicesRequested());
        }
      },
    );
  }

  void _onBackPressed(
    OnboardingBackPressed event,
    Emitter<StylistOnboardingState> emit,
  ) {
    if (state.data.currentStep <= 0 || state.data.currentStep == 1) {
      return;
    }
    emit(
      StylistOnboardingState(
        state.data.copyWith(currentStep: state.data.currentStep - 1),
      ),
    );
  }

  void _onBasicInfoChanged(
    BasicInfoChanged event,
    Emitter<StylistOnboardingState> emit,
  ) {
    emit(
      StylistOnboardingState(
        state.data.copyWith(
          fullName: event.fullName,
          email: event.email,
          phone: event.phone,
          businessName: event.businessName,
          accountHolderName: event.fullName,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onLocationRequested(
    CurrentLocationRequested event,
    Emitter<StylistOnboardingState> emit,
  ) async {
    emit(
      StylistOnboardingState(
        state.data.copyWith(
          isFetchingLocation: true,
          clearLocationError: true,
          clearError: true,
        ),
      ),
    );

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is required to continue.');
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.isEmpty ? null : placemarks.first;
      final address = [
        place?.street,
        place?.subLocality,
        place?.locality,
        place?.administrativeArea,
        place?.country,
      ].where((part) => (part ?? '').trim().isNotEmpty).join(', ');

      emit(
        StylistOnboardingState(
          state.data.copyWith(
            latitude: position.latitude,
            longitude: position.longitude,
            locationAddress: address.isEmpty
                ? 'Current location detected'
                : address,
            isFetchingLocation: false,
            clearLocationError: true,
          ),
        ),
      );
    } catch (_) {
      emit(
        StylistOnboardingState(
          state.data.copyWith(
            isFetchingLocation: false,
            locationError:
                'We could not detect your location. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _onBasicInfoSubmitted(
    BasicInfoSubmitted event,
    Emitter<StylistOnboardingState> emit,
  ) async {
    if (!state.data.canContinueBasicInfo) {
      emit(
        StylistOnboardingState(
          state.data.copyWith(
            errorMessage: 'Please complete the basic information.',
          ),
        ),
      );
      return;
    }
    emit(
      StylistOnboardingState(
        state.data.copyWith(isLoading: true, clearError: true),
      ),
    );
    final result = await saveBasicInfo(state.data);
    result.fold(
      (failure) => emit(
        StylistOnboardingState(
          state.data.copyWith(isLoading: false, errorMessage: failure.message),
        ),
      ),
      (stylistId) => emit(
        StylistOnboardingState(
          state.data.copyWith(
            isLoading: false,
            stylistId: stylistId,
            currentStep: 1,
            flowStatus: OnboardingFlowStatus.inProgress,
          ),
        ),
      ),
    );
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<StylistOnboardingState> emit,
  ) async {
    final email = state.data.email?.trim();
    if (email == null || email.isEmpty || event.otp.length != 6) {
      emit(
        StylistOnboardingState(
          state.data.copyWith(errorMessage: 'Enter the 6 digit email code.'),
        ),
      );
      return;
    }
    emit(
      StylistOnboardingState(
        state.data.copyWith(isLoading: true, clearError: true),
      ),
    );
    final result = await verifyStylistOtp(
      email: email,
      otp: event.otp,
      state: state.data,
    );
    result.fold(
      (failure) => emit(
        StylistOnboardingState(
          state.data.copyWith(isLoading: false, errorMessage: failure.message),
        ),
      ),
      (stylistId) => emit(
        StylistOnboardingState(
          state.data.copyWith(
            isLoading: false,
            stylistId: stylistId,
            currentStep: 2,
          ),
        ),
      ),
    );
  }

  Future<void> _onOtpResent(
    OtpResent event,
    Emitter<StylistOnboardingState> emit,
  ) async {
    final email = state.data.email?.trim();
    if (email == null || email.isEmpty) return;
    final result = await resendStylistOtp(email);
    result.fold(
      (failure) => emit(
        StylistOnboardingState(
          state.data.copyWith(errorMessage: failure.message),
        ),
      ),
      (_) => emit(
        StylistOnboardingState(
          state.data.copyWith(warningMessage: 'Code sent again.'),
        ),
      ),
    );
  }

  void _onKycFileChanged(
    KycFileChanged event,
    Emitter<StylistOnboardingState> emit,
  ) {
    if (event.type == 'front') {
      emit(
        StylistOnboardingState(
          state.data.copyWith(nationalIdFront: event.file),
        ),
      );
    } else if (event.type == 'back') {
      emit(
        StylistOnboardingState(state.data.copyWith(nationalIdBack: event.file)),
      );
    } else {
      // TODO: replace this fallback selfie with Smile ID SmartSelfie in production.
      emit(
        StylistOnboardingState(
          state.data.copyWith(
            selfieFile: event.file,
            selfieImagePath: event.file.path,
            selfieVerified: true,
          ),
        ),
      );
    }
  }

  Future<void> _onKycSubmitted(
    KycSubmitted event,
    Emitter<StylistOnboardingState> emit,
  ) async {
    final data = state.data;
    if (!data.canContinueKyc || data.stylistId == null) {
      emit(
        StylistOnboardingState(
          data.copyWith(errorMessage: 'Please complete identity verification.'),
        ),
      );
      return;
    }
    emit(
      StylistOnboardingState(data.copyWith(isLoading: true, clearError: true)),
    );
    final result = await saveKyc(
      stylistId: data.stylistId!,
      nationalIdFront: data.nationalIdFront!,
      nationalIdBack: data.nationalIdBack!,
      selfieFile: data.selfieFile!,
    );
    result.fold(
      (failure) => emit(
        StylistOnboardingState(
          data.copyWith(isLoading: false, errorMessage: failure.message),
        ),
      ),
      (_) {
        emit(
          StylistOnboardingState(
            data.copyWith(isLoading: false, currentStep: 3),
          ),
        );
        add(const ServicesRequested());
      },
    );
  }

  Future<void> _onServicesRequested(
    ServicesRequested event,
    Emitter<StylistOnboardingState> emit,
  ) async {
    final result = await getActiveServices();
    result.fold(
      (failure) => emit(
        StylistOnboardingState(
          state.data.copyWith(errorMessage: failure.message),
        ),
      ),
      (services) =>
          emit(StylistOnboardingState(state.data.copyWith(services: services))),
    );
  }

  void _onServiceSelectionToggled(
    ServiceSelectionToggled event,
    Emitter<StylistOnboardingState> emit,
  ) {
    final ids = [...state.data.selectedServiceIds];
    final prices = Map<String, double>.from(state.data.servicePrices);
    if (ids.contains(event.service.id)) {
      ids.remove(event.service.id);
      prices.remove(event.service.id);
    } else {
      ids.add(event.service.id);
      prices[event.service.id] = event.price ?? event.service.basePrice;
    }
    emit(
      StylistOnboardingState(
        state.data.copyWith(selectedServiceIds: ids, servicePrices: prices),
      ),
    );
  }

  void _onAvailabilityUpdated(
    AvailabilityUpdated event,
    Emitter<StylistOnboardingState> emit,
  ) {
    final slots = state.data.availability
        .map(
          (slot) => slot.dayOfWeek == event.slot.dayOfWeek ? event.slot : slot,
        )
        .toList();
    emit(StylistOnboardingState(state.data.copyWith(availability: slots)));
  }

  Future<void> _onProfessionalSubmitted(
    ProfessionalDetailsSubmitted event,
    Emitter<StylistOnboardingState> emit,
  ) async {
    final data = state.data;
    if (!data.canContinueProfessional || data.stylistId == null) {
      emit(
        StylistOnboardingState(
          data.copyWith(
            errorMessage: 'Add a license, service, and availability.',
          ),
        ),
      );
      return;
    }
    emit(
      StylistOnboardingState(
        data.copyWith(isLoading: true, uploadProgress: 0, clearError: true),
      ),
    );
    final result = await saveProfessionalDetails(
      stylistId: data.stylistId!,
      licenseFile: data.licenseFile!,
      yearsExperience: data.yearsExperience,
      selectedServiceIds: data.selectedServiceIds,
      servicePrices: data.servicePrices,
      availability: data.availability,
      serviceRadiusKm: data.serviceRadiusKm,
      portfolioPhotos: data.portfolioPhotos,
      onProgress: (progress) {
        add(OnboardingMessageCleared());
      },
    );
    result.fold(
      (failure) => emit(
        StylistOnboardingState(
          data.copyWith(isLoading: false, errorMessage: failure.message),
        ),
      ),
      (warning) => emit(
        StylistOnboardingState(
          data.copyWith(
            isLoading: false,
            currentStep: 4,
            warningMessage: warning,
            uploadProgress: 1,
          ),
        ),
      ),
    );
  }

  void _onWalletChanged(
    WalletInfoChanged event,
    Emitter<StylistOnboardingState> emit,
  ) {
    final card = (event.cardNumber ?? '').replaceAll(RegExp(r'\D'), '');
    final last4 = card.length >= 4 ? card.substring(card.length - 4) : null;
    final cardType = card.isEmpty ? null : _cardType(card[0]);
    emit(
      StylistOnboardingState(
        state.data.copyWith(
          bankName: event.bankName,
          accountHolderName: event.accountHolderName,
          accountNumber: event.accountNumber,
          termsAccepted: event.termsAccepted,
          addDebitCard: event.addDebitCard,
          cardLast4: last4,
          cardType: cardType,
          clearCard: event.addDebitCard == false,
        ),
      ),
    );
  }

  Future<void> _onWalletSubmitted(
    WalletSubmitted event,
    Emitter<StylistOnboardingState> emit,
  ) async {
    final data = state.data;
    if (!data.canSubmitWallet || data.stylistId == null) {
      emit(
        StylistOnboardingState(
          data.copyWith(
            errorMessage: 'Complete bank details and accept the terms.',
          ),
        ),
      );
      return;
    }
    emit(
      StylistOnboardingState(data.copyWith(isLoading: true, clearError: true)),
    );
    final result = await submitWallet(
      stylistId: data.stylistId!,
      bankName: data.bankName!.trim(),
      accountHolderName: data.accountHolderName!.trim(),
      accountNumber: data.accountNumber!.trim(),
      cardLast4: data.cardLast4,
      cardType: data.cardType,
    );
    result.fold(
      (failure) => emit(
        StylistOnboardingState(
          data.copyWith(isLoading: false, errorMessage: failure.message),
        ),
      ),
      (_) => emit(
        StylistOnboardingState(
          data.copyWith(
            isLoading: false,
            flowStatus: OnboardingFlowStatus.submitted,
          ),
        ),
      ),
    );
  }

  Future<void> _onSignOutRequested(
    SubmittedSignOutRequested event,
    Emitter<StylistOnboardingState> emit,
  ) async {
    await signOutStylist();
    emit(
      StylistOnboardingState(
        OnboardingStateEntity.initial().copyWith(
          flowStatus: OnboardingFlowStatus.fresh,
        ),
      ),
    );
  }

  String _cardType(String firstDigit) {
    switch (firstDigit) {
      case '4':
        return 'visa';
      case '5':
        return 'mastercard';
      default:
        return 'debit';
    }
  }
}
