import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/config/supabase_config.dart';
import 'package:ur_stylist/features/auth/onboarding/data/datasources/stylist_onboarding_remote_data_source.dart';
import 'package:ur_stylist/features/auth/onboarding/data/models/service_model.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/onboarding_flow_status.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/onboarding_state_entity.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/service_entity.dart';

class StylistOnboardingRemoteDataSourceImpl
    implements StylistOnboardingRemoteDataSource {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<OnboardingStateEntity> loadExistingOnboarding() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return OnboardingStateEntity.initial().copyWith(
        flowStatus: OnboardingFlowStatus.fresh,
      );
    }

    final response = await _client
        .from('stylists')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (response == null) {
      return OnboardingStateEntity.initial().copyWith(
        email: user.email,
        flowStatus: OnboardingFlowStatus.fresh,
      );
    }

    final stylist = Map<String, dynamic>.from(response);
    final status = (stylist['onboarding_status'] ?? 'basic_info').toString();
    final userRow = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    final publicUser = userRow == null
        ? null
        : Map<String, dynamic>.from(userRow);

    return OnboardingStateEntity.initial().copyWith(
      fullName: publicUser?['name']?.toString(),
      email: publicUser?['email']?.toString() ?? user.email,
      phone: publicUser?['phone']?.toString(),
      businessName: stylist['business_name']?.toString(),
      latitude: double.tryParse((stylist['latitude'] ?? '').toString()),
      longitude: double.tryParse((stylist['longitude'] ?? '').toString()),
      serviceRadiusKm:
          int.tryParse((stylist['service_radius_km'] ?? '10').toString()) ?? 10,
      yearsExperience:
          int.tryParse((stylist['years_experience'] ?? '0').toString()) ?? 0,
      stylistId: stylist['id']?.toString(),
      currentStep: _stepForStatus(status),
      rejectionReason: stylist['rejection_reason']?.toString(),
      flowStatus: _flowForStatus(status),
    );
  }

  @override
  Future<String?> saveBasicInfo(OnboardingStateEntity state) async {
    final email = state.email?.trim();
    if (email == null || email.isEmpty) {
      throw Exception('Please enter a valid email address.');
    }

    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
      data: {
        'name': state.fullName,
        'phone': state.phone,
        'business_name': state.businessName,
      },
    );

    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    return _upsertBasicRows(state, user.id);
  }

  @override
  Future<String> verifyEmailOtp({
    required String email,
    required String otp,
    required OnboardingStateEntity state,
  }) async {
    final response = await _client.auth.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.email,
    );
    final user = response.user ?? _client.auth.currentUser;
    if (user == null) {
      throw Exception('We could not verify your email. Please try again.');
    }

    final stylistId = state.stylistId ?? await _upsertBasicRows(state, user.id);
    await _client
        .from('stylists')
        .update({'onboarding_status': 'email_verified'})
        .eq('id', stylistId);

    return stylistId;
  }

  @override
  Future<void> resendOtp(String email) async {
    await _client.auth.signInWithOtp(email: email, shouldCreateUser: true);
  }

  @override
  Future<void> saveKyc({
    required String stylistId,
    required File nationalIdFront,
    required File nationalIdBack,
    required File selfieFile,
  }) async {
    final userId = _requireUserId();
    final frontPath = await _uploadPhoto(
      bucket: 'stylist-kyc-docs',
      path: '$userId/id_front.jpg',
      file: nationalIdFront,
      publicUrl: false,
    );
    final backPath = await _uploadPhoto(
      bucket: 'stylist-kyc-docs',
      path: '$userId/id_back.jpg',
      file: nationalIdBack,
      publicUrl: false,
    );
    final selfiePath = await _uploadPhoto(
      bucket: 'stylist-kyc-docs',
      path: '$userId/selfie.jpg',
      file: selfieFile,
      publicUrl: false,
    );

    await _client.from('stylist_documents').upsert([
      {
        'stylist_id': stylistId,
        'type': 'national_id_front',
        'file_url': frontPath,
      },
      {
        'stylist_id': stylistId,
        'type': 'national_id_back',
        'file_url': backPath,
      },
      {'stylist_id': stylistId, 'type': 'selfie', 'file_url': selfiePath},
    ]);

    await _client
        .from('stylists')
        .update({'onboarding_status': 'kyc_submitted'})
        .eq('id', stylistId);
  }

  @override
  Future<List<ServiceEntity>> getActiveServices() async {
    final response = await _client
        .from('services')
        .select(
          'id, name, description, duration_minutes, base_price, min_price, icon_url',
        )
        .eq('is_active', true)
        .order('name');

    return (response as List<dynamic>)
        .map((item) => ServiceModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<String?> saveProfessionalDetails({
    required String stylistId,
    required File licenseFile,
    required int yearsExperience,
    required List<String> selectedServiceIds,
    required Map<String, double> servicePrices,
    required List<AvailabilitySlot> availability,
    required int serviceRadiusKm,
    required List<File> portfolioPhotos,
    required void Function(double progress) onProgress,
  }) async {
    final userId = _requireUserId();
    final licenseExt = _extensionFor(licenseFile.path, fallback: 'jpg');
    final licensePath = await _uploadMaybePhoto(
      bucket: 'stylist-licenses',
      path: '$userId/license.$licenseExt',
      file: licenseFile,
      publicUrl: false,
    );

    await _client.from('stylist_documents').insert({
      'stylist_id': stylistId,
      'type': 'license',
      'file_url': licensePath,
    });

    String? warning;
    var completed = 0;
    for (final photo in portfolioPhotos) {
      try {
        final path = '$userId/${DateTime.now().microsecondsSinceEpoch}.jpg';
        final url = await _uploadPhoto(
          bucket: 'stylist-portfolios',
          path: path,
          file: photo,
          publicUrl: true,
        );
        await _client.from('stylist_portfolio').insert({
          'stylist_id': stylistId,
          'image_url': url,
        });
      } catch (_) {
        warning =
            'Some portfolio photos could not upload. You can retry later.';
      } finally {
        completed++;
        onProgress(
          portfolioPhotos.isEmpty ? 1 : completed / portfolioPhotos.length,
        );
      }
    }

    final serviceRows = selectedServiceIds
        .map(
          (serviceId) => {
            'stylists_id': stylistId,
            'service_id': serviceId,
            'price': servicePrices[serviceId] ?? 0,
            'is_available': true,
          },
        )
        .toList();
    if (serviceRows.isNotEmpty) {
      await _client
          .from('stylists_services')
          .upsert(serviceRows, onConflict: 'stylists_id,service_id');
    }

    final availabilityRows = availability
        .where((slot) => slot.isAvailable)
        .map(
          (slot) => {
            'stylists_id': stylistId,
            'day_of_week': slot.dayOfWeek,
            'start_time': slot.startTimeText,
            'end_time': slot.endTimeText,
            'is_available': true,
          },
        )
        .toList();
    if (availabilityRows.isNotEmpty) {
      await _client
          .from('stylists_availability')
          .upsert(availabilityRows, onConflict: 'stylists_id,day_of_week');
    }

    await _client
        .from('stylists')
        .update({
          'years_experience': yearsExperience,
          'service_radius_km': serviceRadiusKm,
          'onboarding_status': 'professional_submitted',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', stylistId);

    return warning;
  }

  @override
  Future<void> submitWallet({
    required String stylistId,
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    String? cardLast4,
    String? cardType,
  }) async {
    final payoutPayload = {
      'stylist_id': stylistId,
      'bank_name': bankName,
      'account_holder_name': accountHolderName,
      'account_number': accountNumber,
      'metadata': {
        if (cardLast4 != null) 'card_last4': cardLast4,
        if (cardType != null) 'card_type': cardType,
      },
      'is_primary': true,
    };
    final existingPayout = await _client
        .from('stylist_payout_accounts')
        .select('id')
        .eq('stylist_id', stylistId)
        .eq('is_primary', true)
        .maybeSingle();
    if (existingPayout == null) {
      await _client.from('stylist_payout_accounts').insert(payoutPayload);
    } else {
      await _client
          .from('stylist_payout_accounts')
          .update(payoutPayload)
          .eq('id', existingPayout['id']);
    }

    await _client.from('wallets').upsert({
      'stylist_id': stylistId,
      'balance': 0,
      'currency': 'etb',
    }, onConflict: 'stylist_id');

    await _client
        .from('stylists')
        .update({'onboarding_status': 'wallet_done'})
        .eq('id', stylistId);
  }

  @override
  Future<void> savePassword({
    required String stylistId,
    required String password,
  }) async {
    final userId = _requireUserId();
    await _client.auth.updateUser(UserAttributes(password: password));
    await _client
        .from('stylists')
        .update({
          'onboarding_status': 'pending_review',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', stylistId)
        .eq('user_id', userId);
    // TODO: trigger push notification or Edge Function for admin review queue.
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<String> _upsertBasicRows(
    OnboardingStateEntity state,
    String userId,
  ) async {
    final name = state.fullName?.trim() ?? '';
    final email = state.email?.trim() ?? '';
    final phone = state.phone?.trim() ?? '';

    await _client.from('users').upsert({
      'id': userId,
      'email': email,
      'phone': phone,
      'name': name,
    }, onConflict: 'id');

    final existing = await _client
        .from('stylists')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    final profilePhotoUrl = state.profilePhoto == null
        ? null
        : await _uploadPhoto(
            bucket: 'stylist-profile-photos',
            path: '$userId/profile.jpg',
            file: state.profilePhoto!,
            publicUrl: true,
          );

    final payload = {
      'user_id': userId,
      'business_name': state.businessName?.trim(),
      'latitude': state.latitude,
      'longitude': state.longitude,
      'onboarding_status': 'basic_info',
      if (profilePhotoUrl != null) 'image_url': profilePhotoUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (existing != null) {
      final existingId = existing['id'].toString();
      await _client.from('stylists').update(payload).eq('id', existingId);
      return existingId;
    }

    final inserted = await _client
        .from('stylists')
        .insert(payload)
        .select('id')
        .single();
    return inserted['id'].toString();
  }

  Future<String> _uploadMaybePhoto({
    required String bucket,
    required String path,
    required File file,
    required bool publicUrl,
  }) async {
    final ext = _extensionFor(file.path);
    if (ext == 'pdf') {
      await _client.storage
          .from(bucket)
          .upload(path, file, fileOptions: const FileOptions(upsert: true));
      return publicUrl
          ? _client.storage.from(bucket).getPublicUrl(path)
          : '$bucket/$path';
    }
    return _uploadPhoto(
      bucket: bucket,
      path: path,
      file: file,
      publicUrl: publicUrl,
    );
  }

  Future<String> _uploadPhoto({
    required String bucket,
    required String path,
    required File file,
    required bool publicUrl,
  }) async {
    final uploadFile = await _compressPhoto(file);
    await _client.storage
        .from(bucket)
        .upload(
          path,
          uploadFile,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
    return publicUrl
        ? _client.storage.from(bucket).getPublicUrl(path)
        : '$bucket/$path';
  }

  Future<File> _compressPhoto(File file) async {
    final lowerPath = file.path.toLowerCase();
    if (lowerPath.endsWith('.pdf')) {
      return file;
    }

    final targetPath = p.join(
      Directory.systemTemp.path,
      'stylist_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 800,
      minHeight: 800,
      quality: 80,
      format: CompressFormat.jpeg,
    );
    return compressed == null ? file : File(compressed.path);
  }

  String _requireUserId() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Please sign in again to continue onboarding.');
    }
    return user.id;
  }

  String _extensionFor(String path, {String fallback = 'jpg'}) {
    final ext = p.extension(path).replaceFirst('.', '').toLowerCase();
    return ext.isEmpty ? fallback : ext;
  }

  int _stepForStatus(String status) {
    switch (status) {
      case 'basic_info':
        return 1;
      case 'email_verified':
        return 2;
      case 'kyc_submitted':
        return 3;
      case 'professional_submitted':
        return 4;
      case 'wallet_done':
        return 5;
      default:
        return 0;
    }
  }

  OnboardingFlowStatus _flowForStatus(String status) {
    switch (status) {
      case 'pending_review':
        return OnboardingFlowStatus.pendingReview;
      case 'rejected':
        return OnboardingFlowStatus.rejected;
      case 'approved':
        return OnboardingFlowStatus.approved;
      default:
        return OnboardingFlowStatus.inProgress;
    }
  }
}
