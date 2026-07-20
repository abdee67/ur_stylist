import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/onboarding/domain/repositories/stylist_onboarding_repository.dart';

class SubmitWallet {
  final StylistOnboardingRepository repository;

  SubmitWallet(this.repository);

  Future<Either<Failures, void>> call({
    required String stylistId,
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    String? cardLast4,
    String? cardType,
  }) {
    return repository.submitWallet(
      stylistId: stylistId,
      bankName: bankName,
      accountHolderName: accountHolderName,
      accountNumber: accountNumber,
      cardLast4: cardLast4,
      cardType: cardType,
    );
  }
}
