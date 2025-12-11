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
    
    // ✅ FIX: Call _handleNewMessage inside the listener
    signalR.messageStream.listen((message) {
        _handleNewMessage(message); 
    }); 
  }

  void _handleNewMessage(MessageDto message) {
    print("🔔 Global Listener: Received ${message.content}");

    // 1. Update List
    context.read<ConversationsCubit>().updateConversationOnMessage(message);

    // 2. Show Notification
    NotificationService().showNotification(
      title: "New Message",
      body: message.content, 
      conversationId: message.conversationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}