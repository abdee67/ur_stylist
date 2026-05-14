import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';

class BookingHistoryTile extends StatelessWidget {
  final BookingEntity booking;

  const BookingHistoryTile({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final completed = booking.status == BookingStatus.completed;
    return ExpansionTile(
      title: Text(booking.serviceName),
      subtitle: Text(
        '${DateFormat('MMM d, h:mm a').format(booking.scheduledAt)} • ${booking.clientName}',
      ),
      trailing: Chip(
        label: Text(_label),
        backgroundColor: completed ? Colors.green.shade50 : Colors.red.shade50,
        labelStyle: TextStyle(color: completed ? Colors.green : Colors.red),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              completed
                  ? 'Earned ETB ${booking.stylistEarnings.toStringAsFixed(2)}'
                  : booking.cancellationReason ?? 'No extra details',
            ),
          ),
        ),
      ],
    );
  }

  String get _label {
    switch (booking.status) {
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.missed:
        return 'Missed';
      default:
        return 'Other';
    }
  }
}
