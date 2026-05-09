import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ur_stylist/core/constants/app_routes.dart';
import 'package:ur_stylist/features/auth/presentation/screens/forgotPassword.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/pages/onboarding_wrapper.dart';
import 'package:ur_stylist/features/auth/presentation/screens/resetPassword.dart';
import 'package:ur_stylist/features/auth/presentation/screens/welcome_screen.dart';
import 'package:ur_stylist/features/auth/presentation/screens/login_screen.dart';
import 'package:ur_stylist/features/dashboard/dashboard_wrapper.dart';
import 'package:ur_stylist/features/home/presentation/pages/home_screen.dart';
import 'package:ur_stylist/features/profile/presentation/screens/settings_screen.dart';

class AppRouter {
  final bool showOnboarding;
  AppRouter({required this.showOnboarding});
  // Global navigator key is useful for specialized dialogs/snackbars
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: showOnboarding
        ? AppRoutes.onboardingScreen
        : AppRoutes.loginScreen,
    routes: [
      GoRoute(
        path: AppRoutes.onboardingScreen,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginScreen,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signupScreen,
        builder: (_, __) => const OnboardingWrapper(),
      ),
      GoRoute(
        path: AppRoutes.stylistOnboarding,
        builder: (_, __) => const OnboardingWrapper(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.homeScreen,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),

          // Additional branches can be added here for other tabs
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordScreen,
        builder: (_, __) => ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPasswordScreen,
        builder: (_, __) => ResetPasswordScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: ${state.error}')),
      );
    },
  );
}
