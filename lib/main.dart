
import 'package:chat/core/app_config.dart';
import 'package:chat/logic/conversations_cubit/conversations_cubit.dart';
import 'package:chat/presentation/global_message_listener.dart';
import 'package:chat/services/auth_repository.dart';
import 'package:chat/logic/auth_cubit/auth_cubit.dart';
import 'package:chat/services/conversation_service.dart';
import 'package:chat/services/notification_service.dart';
import 'package:chat/services/signalr_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Init Services
  final notificationService = NotificationService();
  await notificationService.init();
  
  final signalRService = SignalRService();
  // Pass your token here (usually retrieved from storage)
  // await signalRService.initSignalR("USER_AUTH_TOKEN");

  runApp(MyApp(
    signalRService: signalRService,
    notificationService: notificationService
  ));
}

class MyApp extends StatelessWidget {
  final SignalRService signalRService;
  final NotificationService notificationService;

  const MyApp({required this.signalRService, required this.notificationService, super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize Repository
    final authRepository = AuthRepository();
    final conversationService = ConversationService(); // ✅ Create Service
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: signalRService),
        RepositoryProvider.value(value: notificationService),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: conversationService), // ✅ Inject Service
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(authRepository),
          ),
          // ✅ FIX: Provide ConversationsCubit GLOBALLY
          // This ensures the list updates even if you are on the Chat Page
          BlocProvider<ConversationsCubit>(
            create: (context) => ConversationsCubit(
               conversationService, 
               AppConfig.userId ?? "" // Ensure UserID is ready
            )..loadConversations(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          title: 'Flutter Chat',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          // ✅ FIX: This injects the listener into the widget tree PERMANENTLY
          // regardless of which route (page) is currently visible.
          builder: (context, child) {
            return GlobalMessageListener(child: child!); 
          },
        ),
      ),
    );
  }
}
