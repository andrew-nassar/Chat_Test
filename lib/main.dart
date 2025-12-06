import 'package:chat/services/auth_repository.dart';
import 'package:chat/logic/auth_cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize Repository
    final authRepository = AuthRepository();
    return MultiBlocProvider(
      providers: [
        // 2. Provide Cubit
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // 1. Set the initial route to LOGIN
        initialRoute: AppRoutes.splash, // Start here        // 2. Pass the map
        routes: AppRoutes.routes,
        title: 'Flutter Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
      ),
    );
  }
}

