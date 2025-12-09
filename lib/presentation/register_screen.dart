import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Logic
import '../logic/auth_cubit/auth_cubit.dart';
import '../logic/auth_cubit/auth_state.dart';

// Widgets
import 'widgets/custom_text_field.dart';
import 'widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Dependencies
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // --- Actions ---

  void _onRegisterPressed() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
            _nameController.text.trim(),
            _phoneController.text.trim(),
            _passController.text.trim(),
          );
    }
  }

  void _navigateBackToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Match Login Screen background
      backgroundColor: Colors.white,
      // Transparent AppBar just for the Back Button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: _navigateBackToLogin,
        ),
      ),
      // Extend body behind app bar if you want a full screen feel, 
      // but standard is fine here.
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Depending on flow: Go to Home OR Go back to Login to sign in
            // For now, let's assume auto-login or go back
            Navigator.pop(context); 
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Account created! Please login."),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
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
                        _buildHeader(theme),
                        const SizedBox(height: 32),
                        _buildForm(),
                        const SizedBox(height: 32),
                        _buildRegisterButton(state is AuthLoading),
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

  // --- Sub-Widgets ---

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_add_outlined, 
              size: 40, color: theme.primaryColor),
        ),
        const SizedBox(height: 24),
        Text(
          "Create Account",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Join us and start chatting today!",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return AutofillGroup(
      child: Column(
        children: [
          // Full Name
          CustomTextField(
            controller: _nameController,
            label: "Full Name",
            icon: Icons.person_outline_rounded,
            type: TextInputType.name,
            action: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            validator: (val) {
              if (val == null || val.isEmpty) return "Name is required";
              if (val.length < 3) return "Name is too short";
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Phone
          CustomTextField(
            controller: _phoneController,
            label: "Phone Number",
            icon: Icons.phone_android_rounded,
            type: TextInputType.phone,
            action: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            validator: (val) {
              if (val == null || val.isEmpty) return "Phone number is required";
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Password
          CustomTextField(
            controller: _passController,
            label: "Password",
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            action: TextInputAction.done,
            // 'newPassword' tells the OS to offer to save this credential
            autofillHints: const [AutofillHints.newPassword], 
            validator: (val) {
              if (val == null || val.isEmpty) return "Password is required";
              if (val.length < 6) return "Password must be at least 6 characters";
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return SizedBox(
      height: 50,
      child: CustomButton(
        text: "Sign Up",
        isLoading: isLoading,
        onPressed:  isLoading ? (){} : _onRegisterPressed,
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: _navigateBackToLogin,
          child: Text(
            "Login",
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