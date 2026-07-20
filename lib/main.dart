import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ur_stylist/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_bloc.dart';
import 'package:ur_stylist/features/home/presentation/bloc/home_bloc.dart';
import 'package:ur_stylist/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ur_stylist/features/shell/presentation/bloc/main_shell_cubit.dart';
import 'package:ur_stylist/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:ur_stylist/injection_container.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ur_stylist/core/constants/app_routes.dart';
import 'package:ur_stylist/core/utils/session_expiry_policy.dart';
import 'config/supabase_config.dart';
import 'routes/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await SupabaseConfig.init();
  Stripe.urlScheme = 'urstylist';
  initDependency(); //initializing getit for dependency injection
  runApp(const URStylistApp());
}

class URStylistApp extends StatefulWidget {
  const URStylistApp({super.key});
  @override
  State<URStylistApp> createState() => _URStylistAppState();
}

class _URStylistAppState extends State<URStylistApp>
    with WidgetsBindingObserver {
  bool showOnboarding = true;
  bool isLoading = true;
  late GoRouter _router;
  bool _routerReady = false;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenForForcedLogout();
    _checkOnboardingStatus();

    ///this suppose to be in splash screen but for now i will put it here to avoid creating another screen just for this purpose
  }

  /// Redirect to the login screen whenever the user becomes signed out, whether
  /// that was a manual sign-out or the client-side expiry policy calling
  /// [SupabaseClient.auth.signOut]. Signing out wipes the local session storage,
  /// so there is nothing to auto-log-in with on the next launch.
  void _listenForForcedLogout() {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (data.event == AuthChangeEvent.signedOut && _routerReady) {
          _router.go(AppRoutes.loginScreen);
        }
      },
      onError: (Object error) {
        // gotrue pushes token-refresh failures onto this stream (e.g.
        // AuthRetryableFetchException when the network is flaky as the app
        // resumes). Without an onError handler these become unhandled
        // exceptions that crash the app. They are transient and gotrue retries
        // on its own, so keep the session and just log in debug.
        if (kDebugMode) {
          debugPrint('Auth state stream error (ignored): $error');
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Left the foreground: stamp the time so we can measure the gap on wake.
        unawaited(SessionExpiryPolicy.markBackgrounded());
        break;
      case AppLifecycleState.resumed:
        // Back in the foreground: enforce the login wall if we were away too
        // long. Active users never reach here mid-use, so they are untouched.
        unawaited(_enforceSessionExpiry());
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _enforceSessionExpiry() async {
    final auth = Supabase.instance.client.auth;
    final expired = await SessionExpiryPolicy.hasExpiredWhileBackgrounded();
    await SessionExpiryPolicy.clear();
    if (expired && auth.currentSession != null) {
      // Local scope clears secure storage and emits signedOut without a network
      // call, so it works even on a flaky connection after a long background.
      // The onAuthStateChange listener turns signedOut into a login redirect.
      try {
        await auth.signOut(scope: SignOutScope.local);
      } catch (_) {
        // Never let a forced logout crash the resume path.
      }
    }
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      setState(() {
        showOnboarding = !hasSeenOnboarding;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        showOnboarding = true;
        isLoading = false;
      });
    }

    // Initialize router after onboarding status is determined
    _router = AppRouter(showOnboarding: showOnboarding).router;
    _routerReady = true;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getit<AuthBloc>()),
        BlocProvider(create: (context) => getit<StylistOnboardingBloc>()),
        BlocProvider(create: (context) => getit<HomeBloc>()),
        BlocProvider(create: (context) => getit<WalletBloc>()),
        BlocProvider(create: (context) => getit<SettingsBloc>()),
        BlocProvider(create: (context) => getit<MainShellCubit>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'UR STYLIST',
        routerConfig: _router,
        theme: ThemeData(
          primaryColor: Colors.blue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          textTheme: TextTheme(
            bodyMedium: TextStyle(fontSize: 16, height: 1.4),
            headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
          ),
        ),
      ),
    );
  }
}
