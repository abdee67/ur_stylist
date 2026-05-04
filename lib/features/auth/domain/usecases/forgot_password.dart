import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/domain/repositories/auth_repository.dart';

class ForgotPassword {
  final AuthRepository authRepository;
  ForgotPassword(this.authRepository);

  Future<Either<Failures, void>> call(String email) async {
    return await authRepository.forgotPassword(email);
  }
}
