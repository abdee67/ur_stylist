import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';
import 'package:ur_stylist/features/home/presentation/bloc/home_bloc.dart';
import 'package:ur_stylist/features/home/presentation/widgets/cash_payment_verification_sheet.dart';

class ActiveBookingCard extends StatelessWidget {
  final BookingEntity booking;

  const ActiveBookingCard({super.key, required this.booking});

  Future<void> _completeBooking(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Complete service?'),
        content: const Text("Are you sure you've finished this service?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) {
      return;
    }

    final paidInCash = await _askCashPaymentMethod(context);
    if (paidInCash == null || !context.mounted) {
      return;
    }

    if (!paidInCash) {
      context.read<HomeBloc>().add(CompleteBookingRequested(booking.id));
      return;
    }

    final navigator = Navigator.of(context);
    final bloc = context.read<HomeBloc>();
    final completed = await _dispatchActionAndWait(
      bloc,
      CompleteBookingRequested(booking.id),
    );

    if (!completed || !navigator.mounted) {
      return;
    }

    final verified = await showCashPaymentVerificationSheet(
      navigator.context,
      booking,
    );

    if (verified) {
      bloc.add(ConfirmCashPaymentRequested(booking.id));
    }
  }

  Future<bool?> _askCashPaymentMethod(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Payment method'),
        content: const Text('Did the client pay this booking in cash?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No, not cash'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Yes, cash'),
          ),
        ],
      ),
    );
    return ok;
  }

  Future<bool> _dispatchActionAndWait(HomeBloc bloc, HomeEvent event) async {
    final completion = bloc.stream
        .skipWhile((state) => !state.isActionLoading)
        .firstWhere((state) => !state.isActionLoading);

    bloc.add(event);

    try {
      final state = await completion.timeout(const Duration(seconds: 20));
      return state.errorMessage == null;
    } on TimeoutException {
      return false;
    }
  }

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
                        await _completeBooking(context);
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
