import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ur_stylist/core/constants/app_routes.dart';
import 'package:ur_stylist/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ur_stylist/features/auth/presentation/bloc/auth_event.dart';
import 'package:ur_stylist/features/auth/presentation/bloc/auth_state.dart';
import 'package:ur_stylist/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ur_stylist/features/settings/presentation/pages/edit_availability_page.dart';
import 'package:ur_stylist/features/settings/presentation/pages/edit_payout_account_page.dart';
import 'package:ur_stylist/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:ur_stylist/features/settings/presentation/pages/manage_portfolio_page.dart';
import 'package:ur_stylist/features/settings/presentation/pages/notification_preferences_page.dart';
import 'package:ur_stylist/features/settings/presentation/widgets/account_status_banner.dart';
import 'package:ur_stylist/features/settings/presentation/widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) context.go(AppRoutes.loginScreen);
        if (state is AccountDeactivated) {
          context.go(AppRoutes.loginScreen);
        }
      },
      child: SafeArea(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state.isLoading && state.profile == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final profile = state.profile;
            if (profile == null) {
              return const Center(child: Text('Profile is not available.'));
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<SettingsBloc>().add(const SettingsStarted()),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundImage: profile.imageUrl == null
                            ? null
                            : NetworkImage(profile.imageUrl!),
                        child: profile.imageUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.businessName.isEmpty
                                  ? profile.name
                                  : profile.businessName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              profile.email,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AccountStatusBanner(status: profile.onboardingStatus),
                  const SizedBox(height: 18),
                  SettingsTile(
                    icon: Iconsax.user_edit,
                    title: 'Profile',
                    subtitle: 'Business info, photo, service radius',
                    onTap: () =>
                        _push(context, EditProfilePage(profile: profile)),
                  ),
                  SettingsTile(
                    icon: Iconsax.calendar_edit,
                    title: 'Availability',
                    subtitle: '${profile.availability.length} saved days',
                    onTap: () => _push(
                      context,
                      EditAvailabilityPage(availability: profile.availability),
                    ),
                  ),
                  SettingsTile(
                    icon: Iconsax.gallery,
                    title: 'Portfolio',
                    subtitle: '${profile.portfolio.length} photos',
                    onTap: () => _push(
                      context,
                      ManagePortfolioPage(photos: profile.portfolio),
                    ),
                  ),
                  SettingsTile(
                    icon: Iconsax.card,
                    title: 'Payout account',
                    subtitle: profile.payoutAccount?.maskedAccount ?? 'Not set',
                    onTap: () => _push(
                      context,
                      EditPayoutAccountPage(account: profile.payoutAccount),
                    ),
                  ),
                  SettingsTile(
                    icon: Iconsax.notification,
                    title: 'Notifications',
                    subtitle: 'Booking and wallet alerts',
                    onTap: () => _push(
                      context,
                      NotificationPreferencesPage(
                        preferences: profile.preferences,
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                  SettingsTile(
                    icon: Iconsax.logout,
                    title: 'Sign out',
                    iconColor: Colors.black54,
                    onTap: () => _confirmSignOut(context),
                  ),
                  SettingsTile(
                    icon: Iconsax.profile_delete,
                    title: 'Deactivate account',
                    iconColor: Colors.red,
                    onTap: () => _confirmDeactivate(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SettingsBloc>(),
          child: page,
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deactivate account?'),
        content: const Text(
          'You will be signed out and your account will stop receiving bookings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<SettingsBloc>().add(const SettingsDeactivateRequested());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Are you sure you want to sign out?'),
        content: const Text('You will be signed out.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(SignOutRequested());
      context.go(AppRoutes.loginScreen);
    }
  }
}
