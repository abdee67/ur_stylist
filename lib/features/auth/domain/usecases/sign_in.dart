import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/auth/domain/repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repo;
  SignIn(this.repo);

  Future<Either<Failures, Session>> call(String email, String password) {
    return repo.signIn(email, password);
  }
}
