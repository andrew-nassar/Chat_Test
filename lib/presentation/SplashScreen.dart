import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../logic/auth_cubit/auth_cubit.dart';
import '../logic/auth_cubit/auth_state.dart';
import '../core/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the check immediately when app starts
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // User exists -> Go to Home
          print("===============${state.userId}");
          AppRoutes.nextReplacement(context, AppRoutes.home,
              arguments: state.userId);
        } else if (state is AuthInitial || state is AuthError) {
          // No user -> Go to Login
          AppRoutes.nextReplacement(context, AppRoutes.login);
        }
      },
      child: Scaffold(
        body: // --- 1. The Animation ---
            Center(
          child: SizedBox(
            height: 250, // ارتفاع ثابت
            width: MediaQuery.of(context).size.width * 0.8, // عرض مرن
            child: Lottie.asset(
              'assets/animations/loading.json',
              fit: BoxFit.contain,
            ),
          ),
        )
      ),
    );
  }
}
