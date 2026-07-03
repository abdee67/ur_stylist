import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';
import 'package:ur_stylist/features/home/presentation/bloc/home_bloc.dart';

class ActiveBookingCard extends StatelessWidget {
  final BookingEntity booking;

  const ActiveBookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final inProgress = booking.status == BookingStatus.inProgress;
    final confirmed = booking.status == BookingStatus.confirmed;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.serviceName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Client: ${booking.clientName}'),
            Text(DateFormat('EEE, MMM d • h:mm a').format(booking.scheduledAt)),
            if (inProgress) ...[
              Text(booking.cleanAddress),
              const SizedBox(height: 12),
              _Elapsed(startedAt: booking.startedAt),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (inProgress) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final lat = booking.latitude;
                        final lng = booking.longitude;
                        if (lat == null || lng == null) return;
                        await launchUrl(
                          Uri.parse('https://maps.google.com?q=$lat,$lng'),
                        );
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (inProgress) {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Complete service?'),
                            content: const Text(
                              "Are you sure you've finished this service?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Complete'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          context.read<HomeBloc>().add(
                            CompleteBookingRequested(booking.id),
                          );
                        }
                      } else if (confirmed) {
                        context.read<HomeBloc>().add(
                          StartBookingRequested(booking.id),
                        );
                      } else {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Decline booking?'),
                            content: const Text(
                              "Are you sure you want to decline this booking?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Decline'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          context.read<HomeBloc>().add(
                            DeclineBookingRequested(
                              booking.id,
                              'Booking declined by stylist',
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      inProgress
                          ? 'Mark completed'
                          : confirmed
                          ? "Let's Start"
                          : "Cancel Booking",
                    ),
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

class _Elapsed extends StatefulWidget {
  final DateTime? startedAt;
  const _Elapsed({required this.startedAt});

  @override
  State<_Elapsed> createState() => _ElapsedState();
}

class _ElapsedState extends State<_Elapsed> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Elapsed: ${_elapsed.inMinutes} min');
  }

  void _tick() {
    final started = widget.startedAt;
    if (started == null || !mounted) return;
    setState(() => _elapsed = DateTime.now().difference(started));
  }
}
