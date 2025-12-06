import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_cubit/auth_cubit.dart';
import '../logic/auth_cubit/auth_state.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        // أي ضغطة خارج TextField هتخفي الـ keyboard و الـ cursor
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(title: const Text("Create Account")),
          body: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                Navigator.pop(context); // Go back to login or go to home
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                          controller: _nameController,
                          label: "Full Name",
                          icon: Icons.person),
                      CustomTextField(
                          controller: _phoneController,
                          label: "Phone Number",
                          icon: Icons.phone,
                          type: TextInputType.phone),
                      CustomTextField(
                          controller: _passController,
                          label: "Password",
                          icon: Icons.lock,
                          isPassword: true),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: "Register",
                        isLoading: state is AuthLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            context.read<AuthCubit>().register(
                                  _nameController.text,
                                  _phoneController.text,
                                  _passController.text,
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
