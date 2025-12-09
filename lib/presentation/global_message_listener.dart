import 'package:chat/Models/message_model.dart';
import 'package:chat/logic/conversations_cubit/conversations_cubit.dart';
import 'package:chat/services/notification_service.dart';
import 'package:chat/services/signalr_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalMessageListener extends StatefulWidget {
  final Widget child;
  const GlobalMessageListener({super.key, required this.child});

  @override
  State<GlobalMessageListener> createState() => _GlobalMessageListenerState();
}

class _GlobalMessageListenerState extends State<GlobalMessageListener> {
  @override
  void initState() {
    super.initState();
    final signalR = context.read<SignalRService>();
    
    signalR.messageStream.listen((message) {
        print("Global Listener: Received ${message.content}"); 
        
        // ✅ FIX: Call the function that handles BOTH List Update AND Notification
        _handleNewMessage(message); 
    }); 
  }

  void _handleNewMessage(MessageDto message) {
    print("🔔 Processing Message: ${message.content}");

    // 1. Update the Conversation List
    context.read<ConversationsCubit>().updateConversationOnMessage(message);

    // 2. Show Notification
    // (Optional: Check if message.senderId != currentUserId to avoid notifying yourself)
    NotificationService().showNotification(
      title: "New Message",
      body: message.content,
    );
  }
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}