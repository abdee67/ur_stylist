import 'package:ur_stylist/features/onboarding/domain/entities/onboarding_state_entity.dart';

class StylistOnboardingState {
  final OnboardingStateEntity data;

  const StylistOnboardingState(this.data);

  factory StylistOnboardingState.initial() {
    return StylistOnboardingState(OnboardingStateEntity.initial());
  }
}
