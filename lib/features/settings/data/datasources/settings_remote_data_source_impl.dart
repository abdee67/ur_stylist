import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/config/supabase_config.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:ur_stylist/features/settings/data/models/stylist_profile_model.dart';
import 'package:ur_stylist/features/settings/domain/entities/stylist_profile_entity.dart';

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
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
  Future<StylistProfileEntity> getProfile() async {
    final stylist = await _stylist();
    final user = await _client
        .from('users')
        .select()
        .eq('id', stylist['user_id'])
        .maybeSingle();
    final portfolio = await _client
        .from('stylist_portfolio')
        .select()
        .eq('stylist_id', stylist['id'])
        .order('created_at', ascending: false);
    final availability = await _client
        .from('stylists_availability')
        .select()
        .eq('stylists_id', stylist['id']);
    final payout = await _client
        .from('stylist_payout_accounts')
        .select()
        .eq('stylist_id', stylist['id'])
        .eq('is_primary', true)
        .maybeSingle();

    return StylistProfileModel.fromParts(
      stylist: stylist,
      user: user == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(user),
      portfolio: portfolio as List,
      availability: availability as List,
      payoutAccount: payout == null ? null : Map<String, dynamic>.from(payout),
    );
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String businessName,
    String? description,
    File? profilePhoto,
    double? latitude,
    double? longitude,
    required int serviceRadiusKm,
  }) async {
    final stylist = await _stylist();
    String? imageUrl;
    if (profilePhoto != null) {
      final path = '${stylist['id']}/profile.jpg';
      final file = await _compress(profilePhoto);
      await _client.storage
          .from('stylist-profile-photos')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      imageUrl = _client.storage
          .from('stylist-profile-photos')
          .getPublicUrl(path);
    }
    await _client
        .from('users')
        .update({'name': name, 'phone': phone})
        .eq('id', stylist['user_id']);
    await _client
        .from('stylists')
        .update({
          'business_name': businessName,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'service_radius_km': serviceRadiusKm,
          if (imageUrl != null) 'image_url': imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', stylist['id']);
  }

  @override
  Future<void> saveAvailability(List<AvailabilitySlot> availability) async {
    final stylist = await _stylist();
    await _client
        .from('stylists_availability')
        .delete()
        .eq('stylists_id', stylist['id']);
    final rows = availability.where((slot) => slot.isAvailable).map((slot) {
      return {
        'stylists_id': stylist['id'],
        'day_of_week': slot.dayOfWeek,
        'start_time': slot.startTimeText,
        'end_time': slot.endTimeText,
        'is_available': true,
      };
    }).toList();
    if (rows.isNotEmpty) {
      await _client.from('stylists_availability').insert(rows);
    }
  }

  @override
  Future<void> addPortfolioPhotos(List<File> photos) async {
    final stylist = await _stylist();
    for (final photo in photos) {
      final path =
          '${stylist['id']}/${DateTime.now().microsecondsSinceEpoch}.jpg';
      final file = await _compress(photo);
      await _client.storage
          .from('stylist-portfolios')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      final url = _client.storage.from('stylist-portfolios').getPublicUrl(path);
      await _client.from('stylist_portfolio').insert({
        'stylist_id': stylist['id'],
        'image_url': url,
      });
    }
  }

  @override
  Future<void> deletePortfolioPhoto(PortfolioPhotoEntity photo) async {
    await _client.from('stylist_portfolio').delete().eq('id', photo.id);
  }

  @override
  Future<void> savePayoutAccount({
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
  }) async {
    final stylist = await _stylist();
    final payload = {
      'stylist_id': stylist['id'],
      'bank_name': bankName,
      'account_holder_name': accountHolderName,
      'account_number': accountNumber,
      'is_primary': true,
    };
    final existing = await _client
        .from('stylist_payout_accounts')
        .select('id')
        .eq('stylist_id', stylist['id'])
        .eq('is_primary', true)
        .maybeSingle();
    if (existing == null) {
      await _client.from('stylist_payout_accounts').insert(payload);
    } else {
      await _client
          .from('stylist_payout_accounts')
          .update(payload)
          .eq('id', existing['id']);
    }
  }

  @override
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    final stylist = await _stylist();
    await _client
        .from('stylists')
        .update({'preferences': preferences})
        .eq('id', stylist['id']);
  }

  Future<File> _compress(File file) async {
    final targetPath = p.join(
      Directory.systemTemp.path,
      'profile_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      minWidth: 1200,
      minHeight: 1200,
      quality: 80,
      format: CompressFormat.jpeg,
    );
    return compressed == null ? file : File(compressed.path);
  }
}
