import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Logic & Routes
import '../core/app_routes.dart';
import '../logic/auth_cubit/auth_cubit.dart';
import '../logic/auth_cubit/auth_state.dart';

// Widgets
import 'widgets/custom_text_field.dart';
import 'widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Dependencies
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // --- Actions ---

  void _onLoginPressed() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
            _phoneController.text.trim(),
            _passController.text.trim(),
          );
    }
  }

  void _navigateToRegister() {
    AppRoutes.next(context, AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    // Use theme data for consistent styling
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AuthSuccess) {
             // Pass the ID cleanly
            AppRoutes.nextReplacement(
              context, 
              AppRoutes.home, 
              arguments: state.userId
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  physics: const ClampingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        _buildHeader(theme),
                        const SizedBox(height: 48),
                        _buildForm(),
                        const SizedBox(height: 24),
                        _buildLoginButton(state is AuthLoading),
                        const SizedBox(height: 24),
                        _buildFooter(theme),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Sub-Widgets (Clean Code Separation) ---

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // Placeholder for Logo - Replace with Image.asset('assets/logo.png')
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_outline_rounded, 
            size: 40, color: theme.primaryColor),
        ),
        const SizedBox(height: 24),
        Text(
          "Welcome Back",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Sign in to continue to your account",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        AutofillGroup(
          child: Column(
            children: [
              CustomTextField(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone_android_rounded,
                type: TextInputType.phone,
                action: TextInputAction.next,
                // UX: Helps the OS suggest phone numbers
                autofillHints: const [AutofillHints.telephoneNumber], 
                validator: (val) {
                   if (val == null || val.isEmpty) return "Phone number is required";
                   // Optional: Add Regex for phone validation here
                   return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passController,
                label: "Password",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                action: TextInputAction.done,
                // UX: Helps password managers fill this in
                autofillHints: const [AutofillHints.password], 
                validator: (val) {
                  if (val == null || val.isEmpty) return "Password is required";
                  if (val.length < 6) return "Password must be at least 6 characters";
                  return null;
                },
              ),
            ],
          ),
        ),
        
        // Optional: Forgot Password Align Right
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
               // Handle Forgot Password
            },
            child: const Text("Forgot Password?"),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isLoading) {
  return SizedBox(
    height: 50,
    child: CustomButton(
      text: "Login",
      isLoading: isLoading,
      // ✅ FIX: Remove "() =>" 
      // If loading, pass null (disables button). 
      // If not, pass the function reference.
      onPressed: isLoading ? (){} : _onLoginPressed, 
    ),
  );
}

  Widget _buildFooter(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: _navigateToRegister,
          child: Text(
            "Register",
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}