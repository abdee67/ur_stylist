import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ur_stylist/core/constants/app_routes.dart';
import 'package:ur_stylist/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ur_stylist/features/auth/presentation/bloc/auth_event.dart';
import 'package:ur_stylist/features/auth/presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _obscurePassword = true;
  bool _otpMode = false;
  bool _isCheckingSession = false;

  @override
  void initState() {
    super.initState();
    _checkStartupSession();
  }

  Future<void> _checkStartupSession() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    context.read<AuthBloc>().add(CheckStartupSessionRequested());
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const _SessionCheckingSplash();
    }

    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerified) {
            context.go(AppRoutes.stylistOnboarding);
          }
          if (state is AuthSuccess) {
            context.go(AppRoutes.homeScreen);
          } else if (state is AuthLoggedOut) {
            setState(() {
              _isCheckingSession = false;
            });
          } else if (state is OtpSent) {
            setState(() {
              _otpMode = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Verification code sent to your email.'),
                backgroundColor: Colors.purple[600],
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red[400],
              ),
            );
            setState(() {
              _isCheckingSession = false;
            });
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.pink[100]!, Colors.purple[100]!],
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.png', // Replace with your logo
                            height: 120,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'UR STLYIST ',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[800],
                              fontFamily: 'PlayfairDisplay',
                            ),
                          ),
                          const Text(
                            'Your beauty journey starts here',
                            style: TextStyle(
                              color: Colors.purple,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[800],
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.purple[300],
                              ),
                              filled: true,
                              fillColor: Colors.pink[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            enabled: !_otpMode,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.purple[300],
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.purple[300],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.pink[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            obscureText: _obscurePassword,
                          ),
                          if (_otpMode) ...[
                            const SizedBox(height: 20),
                            TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                labelText: 'Email code',
                                counterText: '',
                                prefixIcon: Icon(
                                  Icons.pin,
                                  color: Colors.purple[300],
                                ),
                                filled: true,
                                fillColor: Colors.pink[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_otpMode) {
                                  context.read<AuthBloc>().add(
                                    VerifyOtpRequested(
                                      _emailController.text.trim(),
                                      _otpController.text.trim(),
                                    ),
                                  );
                                } else {
                                  context.read<AuthBloc>().add(
                                    SignInRequested(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 5,
                              ),
                              child: state is AuthLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      _otpMode ? 'VERIFY CODE' : 'LOGIN',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          TextButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    if (_emailController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Enter your email first.',
                                          ),
                                          backgroundColor: Colors.red[400],
                                        ),
                                      );
                                      return;
                                    }
                                    context.read<AuthBloc>().add(
                                      SendOtpRequested(
                                        _emailController.text.trim(),
                                      ),
                                    );
                                  },
                            child: Text(
                              _otpMode
                                  ? 'Resend email code'
                                  : 'Sign in with email code',
                              style: TextStyle(color: Colors.purple[600]),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.go(AppRoutes.signupScreen),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.purple[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SessionCheckingSplash extends StatelessWidget {
  const _SessionCheckingSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[100]!, Colors.purple[100]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 120),
              const SizedBox(height: 28),
              CircularProgressIndicator(color: Colors.purple[600]),
              const SizedBox(height: 18),
              Text(
                'Checking your session...',
                style: TextStyle(
                  color: Colors.purple[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
