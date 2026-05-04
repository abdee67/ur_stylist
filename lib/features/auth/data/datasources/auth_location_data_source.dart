import 'package:ur_stylist/features/auth/domain/entities/customer_address_input.dart';

abstract class AuthLocationDataSource {
  Future<CustomerAddressInput> getCurrentLocationAddress();
}
