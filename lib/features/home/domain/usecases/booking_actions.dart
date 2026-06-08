import 'package:dartz/dartz.dart';
import 'package:ur_stylist/core/errors/failures.dart';
import 'package:ur_stylist/features/home/domain/repositories/home_repository.dart';

class AcceptBooking {
  final HomeRepository repository;
  AcceptBooking(this.repository);
  Future<Either<Failures, void>> call(String bookingId) {
    return repository.acceptBooking(bookingId);
  }
}

class DeclineBooking {
  final HomeRepository repository;
  DeclineBooking(this.repository);
  Future<Either<Failures, void>> call(String bookingId, String? reason) {
    return repository.declineBooking(bookingId, reason);
  }
}

class StartBooking {
  final HomeRepository repository;
  StartBooking(this.repository);
  Future<Either<Failures, void>> call(String bookingId) {
    return repository.startBooking(bookingId);
  }
}

class CompleteBooking {
  final HomeRepository repository;
  CompleteBooking(this.repository);
  Future<Either<Failures, void>> call(String bookingId) {
    return repository.completeBooking(bookingId);
  }
}
