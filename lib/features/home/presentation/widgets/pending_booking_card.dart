import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';
import 'package:ur_stylist/features/home/presentation/bloc/home_bloc.dart';
import 'package:ur_stylist/features/home/presentation/widgets/accept_decline_bottom_sheet.dart';
import 'package:ur_stylist/features/home/presentation/widgets/countdown_timer_widget.dart';

class PendingBookingCard extends StatelessWidget {
  final BookingEntity booking;

  const PendingBookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final expired = booking.isExpired;
    final isInProgress = booking.status == BookingStatus.inProgress;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    booking.clientName.characters.first.toUpperCase(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.clientName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${booking.serviceName} • ${booking.durationMinutes} min',
                      ),
                    ],
                  ),
                ),
                CountdownTimerWidget(deadline: booking.acceptDeadline),
              ],
            ),
            const SizedBox(height: 12),
            Text(DateFormat('EEE, MMM d • h:mm a').format(booking.scheduledAt)),
            if (isInProgress)
              Text(
                booking.cleanAddress,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Text(
              'ETB ${booking.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (expired)
              const Chip(label: Text('This booking has expired'))
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final reason = await showDeclineReasonSheet(context);
                        if (context.mounted) {
                          context.read<HomeBloc>().add(
                            DeclineBookingRequested(booking.id, reason),
                          );
                        }
                      },
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: () => context.read<HomeBloc>().add(
                        AcceptBookingRequested(booking.id),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
