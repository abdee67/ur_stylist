import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/config/supabase_config.dart';
import 'package:ur_stylist/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ur_stylist/features/auth/data/models/customer_model.dart';
import 'package:ur_stylist/features/auth/data/models/customer_address_model.dart';
import 'package:ur_stylist/features/auth/domain/entities/customer_address_input.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<Map<String, dynamic>> _stylist() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Please sign in again.');
    return await _client
        .from('stylists')
        .select()
        .eq('user_id', user.id)
        .single();
  }
  @override
  Future<Session> signIn(String email, String password) async {
    try {
      final result = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (result.session == null) {
        throw Exception('Failed to sign in: No session returned');
      }

      final user = result.user ?? _client.auth.currentUser;
      if (user == null) {
        await _signOutQuietly();
        throw Exception('Failed to sign in: No user returned');
      }

      final isStylistAccount = await _isCurrentStylistAccount();
      if (!isStylistAccount) {
        await _signOutQuietly();
        throw Exception(
          'This account is not a stylist account. Please use the UR Beauty app '
          'or complete stylist onboarding first.',
        );
      }

      return result.session!;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<void> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String phone,
    CustomerAddressInput address,
  ) async {
    throw Exception('Use stylist onboarding to create a UR Stylist account.');
  }

  @override
  Future<void> sendOtp(String email) async {
    try {
      await _client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
      );
    } catch (otpError) {
      throw Exception('Failed to send OTP: $otpError');
    }
  }

  @override
  Future<void> verifyOTP(String email, String otp) async {
    try {
      final result = await _client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );
      if (result.session == null) {
        throw Exception('Failed to verify OTP: No session returned');
      }

      final verifiedUser =
          result.user ?? _client.auth.currentUser;
      if (verifiedUser == null) {
        throw Exception('Failed to verify OTP: No user returned');
      }

      final isStylistAccount = await _isCurrentStylistAccount();
      if (!isStylistAccount) {
        await _signOutQuietly();
        throw Exception(
          'This account is not a stylist account. Please use the UR Beauty app '
          'or complete stylist onboarding first.',
        );
      }
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (_client.auth.currentSession == null) return;
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
   @override
  Future<void> deactivateAccount() async {
    final stylist = await _stylist();
    await _client
        .from('stylists')
        .update({'onboarding_status': 'suspended'})
        .eq('id', stylist['id']);
    await signOut();
  }

  @override
  Future<CustomerModel> getCurrentCustomer() async {
    throw Exception('Customer profiles are not available in UR Stylist.');
  }

  @override
  Future<CustomerModel> updateCustomerProfile(CustomerModel customer) async {
    throw Exception('Customer profiles are not available in UR Stylist.');
  }

  Future<bool> _isCurrentStylistAccount() async {
    try {
      final response = await _client.rpc('is_current_stylist');
      return response == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking stylist role: $e');
      }
      return false;
    }
  }

  Future<void> _signOutQuietly() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'urstylist://reset-password/',
      );
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> resetPassword(String email, String password) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(email: email, password: password),
      );
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  @override
  Future<CustomerAddressModel> createCustomerAddress(
    Map<String, dynamic> payload,
  ) async {
    throw Exception('Customer addresses are not available in UR Stylist.');
  }
}
