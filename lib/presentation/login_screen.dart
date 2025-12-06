import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Imports for your Logic and Routes
import '../core/app_routes.dart';
import '../logic/auth_cubit/auth_cubit.dart';
import '../logic/auth_cubit/auth_state.dart';

// Imports for your Widgets and Screens
import 'widgets/custom_text_field.dart';
import 'widgets/custom_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId != null && userId.isNotEmpty) {
      AppRoutes.nextReplacement(context, AppRoutes.home,arguments: userId ); // MainHome
    } 
  }
  @override
  void dispose() {
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector allows tapping anywhere to close the keyboard
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: BlocConsumer<AuthCubit, AuthState>(
          // 1. LISTENER: Handles Navigation and SnackBars (Side Effects)
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AuthSuccess) {
              // --- NAVIGATION LOGIC HERE ---
              print("Login Success: User ID ${state.userId}");

              // Use AppRoutes to replace screen and pass the ID
              AppRoutes.nextReplacement(
                context,
                AppRoutes.home,
                arguments: {state.userId} ,
              );
            }
          },
          // 2. BUILDER: Handles UI Drawing (Loading Spinners, etc.)
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Sign in to continue",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      // Input Fields
                      // Phone Field
                      CustomTextField(
                        controller: _phoneController,
                        label: "Phone Number",
                        icon: Icons.phone,
                        type: TextInputType.phone,
                        action: TextInputAction.next, // Moves to next field
                      ),

// Password Field
                      CustomTextField(
                        controller: _passController,
                        label: "Password",
                        icon: Icons.lock,
                        isPassword:
                            true, // Now has the "Eye" icon automatically!
                        action:
                            TextInputAction.done, // Closes keyboard or submits
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Password is required";
                          }
                          if (val.length < 6) {
                            return "Password must be 6+ chars";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Login Button
                      CustomButton(
                        text: "Login",
                        // Check if loading to show spinner inside button
                        isLoading: state is AuthLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Trigger Cubit
                            context.read<AuthCubit>().login(
                                  _phoneController.text,
                                  _passController.text,
                                );
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // Register Link
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Navigating to Register (Standard push)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text("Don't have an account? Register"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
