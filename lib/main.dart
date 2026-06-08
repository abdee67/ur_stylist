import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ur_stylist/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_bloc.dart';
import 'package:ur_stylist/features/home/presentation/bloc/home_bloc.dart';
import 'package:ur_stylist/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ur_stylist/features/shell/presentation/bloc/main_shell_cubit.dart';
import 'package:ur_stylist/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:ur_stylist/injection_container.dart';
import 'config/supabase_config.dart';
import 'routes/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await SupabaseConfig.init();
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  Stripe.urlScheme = 'urstylist';
  final merchantIdentifier = dotenv.env['STRIPE_MERCHANT_IDENTIFIER'];
  if (merchantIdentifier != null && merchantIdentifier.trim().isNotEmpty) {
    Stripe.merchantIdentifier = merchantIdentifier.trim();
  }
  await Stripe.instance.applySettings();
  initDependency(); //initializing getit for dependency injection
  runApp(const URStylistApp());
}

class URStylistApp extends StatefulWidget {
  const URStylistApp({super.key});
  @override
  State<URStylistApp> createState() => _URStylistAppState();
}

class _URStylistAppState extends State<URStylistApp> {
  bool showOnboarding = true;
  bool isLoading = true;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();

    ///this suppose to be in splash screen but for now i will put it here to avoid creating another screen just for this purpose
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
          primarySwatch: Colors.pink,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}
