import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';
import 'package:ur_stylist/features/home/presentation/bloc/home_bloc.dart';
import 'package:ur_stylist/features/home/presentation/widgets/cash_payment_verification_sheet.dart';

/// Shown for a completed booking whose payment has not settled yet.
///
/// The card is driven entirely by the booking's persisted `payment_status`, so
/// it survives back-navigation, app restarts and refreshes: as long as the
/// money is not in, the stylist can still confirm cash here. Card / online
/// payers settle themselves and the booking leaves this section automatically
/// once the webhook marks it paid.
class AwaitingPaymentCard extends StatelessWidget {
  final BookingEntity booking;

  const AwaitingPaymentCard({super.key, required this.booking});

  Future<void> _confirmCash(BuildContext context) async {
    final bloc = context.read<HomeBloc>();
    final verified = await showCashPaymentVerificationSheet(context, booking);
    if (verified) {
      bloc.add(ConfirmCashPaymentRequested(booking.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF7FA),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.serviceName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Chip(
                  label: Text('Awaiting payment'),
                  backgroundColor: Color(0xFFFCE4EC),
                  labelStyle: TextStyle(color: Colors.pink),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Client: ${booking.clientName}'),
            Text(DateFormat('EEE, MMM d • h:mm a').format(booking.scheduledAt)),
            const SizedBox(height: 4),
            Text(
              'Amount due: ETB ${booking.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmCash(context),
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Confirm cash received'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Received cash? Confirm it with the client QR or OTP. '
              'If the client is paying online, this will clear automatically '
              'once their payment goes through.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
