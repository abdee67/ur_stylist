import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/config/supabase_config.dart';
import 'package:ur_stylist/features/home/data/datasources/home_remote_data_source.dart';
import 'package:ur_stylist/features/home/data/models/booking_model.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';
import 'package:ur_stylist/features/home/domain/entities/today_summary_entity.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<String> getStylistId() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Please sign in again.');
    final response = await _client
        .from('stylists')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
    if (response == null) throw Exception('Stylist profile not found.');
    return response['id'].toString();
  }

  @override
  Future<List<BookingEntity>> getBookings() async {
    final stylistId = await getStylistId();
    final response = await _client
        .from('bookings')
        .select(
          '*, client:customers!bookings_customer_id_fkey(*), customer_address:customer_addresses!bookings_address_fkey(*), booking_services(*, service:services!booking_services_service_fkey(*))',
        )
        .eq('stylist', stylistId)
        .order('scheduled_at', ascending: false);
    return (response as List)
        .map((item) => BookingModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<TodaySummaryEntity> getTodaySummary() async {
    final stylistId = await getStylistId();
    final start = DateTime.now();
    final startOfDay = DateTime(start.year, start.month, start.day).toUtc();
    final wallet = await _client
        .from('wallets')
        .select('id')
        .eq('stylist_id', stylistId)
        .maybeSingle();

    double earnings = 0;
    if (wallet != null) {
      final txs = await _client
          .from('wallet_transactions')
          .select('amount')
          .eq('wallet_id', wallet['id'])
          .eq('source', 'booking_earning')
          .gte('created_at', startOfDay.toIso8601String());
      for (final tx in txs as List) {
        earnings += double.tryParse((tx['amount'] ?? '0').toString()) ?? 0;
      }
    }

    final bookings = await _client
        .from('bookings')
        .select('id')
        .eq('stylist', stylistId)
        .gte('scheduled_at', startOfDay.toIso8601String());
    final stylist = await _client
        .from('stylists')
        .select('avg_rating')
        .eq('id', stylistId)
        .maybeSingle();

    return TodaySummaryEntity(
      earnings: earnings,
      bookingsCount: (bookings as List).length,
      averageRating:
          double.tryParse((stylist?['avg_rating'] ?? '0').toString()) ?? 0,
    );
  }

  @override
  Future<int> getPendingCount() async {
    final stylistId = await getStylistId();
    final response = await _client
        .from('bookings')
        .select('id')
        .eq('stylist', stylistId)
        .eq('status', 'pending');
    return (response as List).length;
  }

  @override
  Future<void> acceptBooking(String bookingId) async {
    await _client
        .from('bookings')
        .update({
          'status': 'confirmed',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
    // TODO: trigger push via FCM/Supabase Edge Function.
  }

  @override
  Future<void> declineBooking(String bookingId, String? reason) async {
    await _client
        .from('bookings')
        .update({
          'status': 'cancelled',
          'cancelled_by': 'stylist',
          'cancellation_reason': reason,
          'cancelled_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
    // TODO: trigger push via FCM/Supabase Edge Function.
  }

  @override
  Future<void> startBooking(String bookingId) async {
    await _client
        .from('bookings')
        .update({
          'status': 'in_progress',
          'started_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
  }

  @override
  Future<void> completeBooking(String bookingId) async {
    await _client
        .from('bookings')
        .update({
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);

    final booking = await _client
        .from('bookings')
        .select('stylist, stylist_earning, total_amount')
        .eq('id', bookingId)
        .single();
    final wallet = await _client
        .from('wallets')
        .select('id, balance')
        .eq('stylist_id', booking['stylist'])
        .single();
    final amount =
        double.tryParse(
          (booking['stylist_earning'] ?? booking['total_amount'] ?? '0')
              .toString(),
        ) ??
        0;
    await _client.from('wallet_transactions').insert({
      'wallet_id': wallet['id'],
      'booking_id': bookingId,
      'transaction_type': 'credit',
      'amount': amount,
      'source': 'booking_earning',
    });
    await _client
        .from('wallets')
        .update({
          'balance':
              (double.tryParse((wallet['balance'] ?? '0').toString()) ?? 0) +
              amount,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', wallet['id']);
    // TODO: trigger push via FCM/Supabase Edge Function.
  }

  @override
  RealtimeChannel subscribeToBookings(String stylistId, VoidCallback onChange) {
    return _client
        .channel('bookings:$stylistId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'stylist',
            value: stylistId,
          ),
          callback: (_) => onChange(),
        )
        .subscribe();
  }
}
