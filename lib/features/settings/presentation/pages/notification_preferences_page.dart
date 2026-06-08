import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ur_stylist/features/settings/presentation/bloc/settings_bloc.dart';

class NotificationPreferencesPage extends StatelessWidget {
  final Map<String, dynamic> preferences;

  const NotificationPreferencesPage({super.key, required this.preferences});

  @override
  Widget build(BuildContext context) {
    final items = {
      'booking_push': 'Booking push alerts',
      'booking_sms': 'Booking SMS alerts',
      'wallet_push': 'Wallet updates',
      'marketing_push': 'Tips and promotions',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items.entries.map((entry) {
          final value = preferences[entry.key] != false;
          return SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: Colors.pink,
            title: Text(entry.value),
            value: value,
            onChanged: (next) {
              context.read<SettingsBloc>().add(
                SettingsPreferenceToggled(entry.key, next),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
