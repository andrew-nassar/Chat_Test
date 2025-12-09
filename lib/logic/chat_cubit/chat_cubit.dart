import 'dart:async';

import 'package:chat/Models/message_model.dart';
import 'package:chat/services/signalr_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/message_service.dart';

// States
abstract class ChatState {}
class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatLoaded extends ChatState {
  final List<MessageDto> messages;
  ChatLoaded(this.messages);
  // ✅ ADD THIS METHOD
  ChatLoaded copyWith({List<MessageDto>? messages}) {
    return ChatLoaded(messages ?? this.messages);
  }
}
class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

// Cubit
class ChatCubit extends Cubit<ChatState> {
  final MessageService _service;
  final String conversationId;
  final String currentUserId;
  final SignalRService _signalRService; // ✅ Add this
  // We keep a local list to easily add new messages without reloading from API
  List<MessageDto> _messages = [];
  late StreamSubscription _signalRSubscription;
  ChatCubit({
    required SignalRService signalRService, // ✅ 1. ADD THIS PARAMETER
    required MessageService service,
    required this.conversationId,
    required this.currentUserId,
  }) : _service = service, _signalRService = signalRService, super(ChatInitial()) {
    
    // ✅ Listen for real-time messages immediately
    _signalRSubscription = _signalRService.messageStream.listen((message) {
      if (message.conversationId == conversationId) {
        onMessageReceived(message);
      }
    });
  }
  @override
  Future<void> close() {
    _signalRSubscription.cancel(); // ✅ Clean up
    return super.close();
  }
  // 1. Load History
  Future<void> loadMessages() async {
    try {
      emit(ChatLoading());
      _messages = await _service.getMessages(conversationId, 1);
      print("================================= "+conversationId);
      emit(ChatLoaded(List.from(_messages)));
    } catch (e) {
      emit(ChatError("Failed to load chat history"));
    }
  }
  
// 2. SEND MESSAGE (Optimistic Update)
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // A. Create a Temporary Message (Optimistic)
    // We use DateTime as a temporary ID until the server confirms
    final tempMessage = MessageDto(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      conversationId: conversationId,
      senderId: currentUserId,
      content: content,
      sentAt: DateTime.now(),
      isRead: false,
    );

    // B. UPDATE UI INSTANTLY
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      // 1. Make a copy of the current list (Essential for Bloc to detect change)
      final List<MessageDto> updatedList = List.from(currentState.messages);
      
      // 2. Add temp message to the START (Index 0) because list is reversed
      updatedList.insert(0, tempMessage);
      
      // 3. Emit new state -> Screen updates immediately
      emit(currentState.copyWith(messages: updatedList));
    }

    // C. SEND TO SERVER (Background)
    try {
      await _service.sendMessage(currentUserId, conversationId, content);
      
      // The SignalR listener will eventually receive the "Real" message.
      // You might get a duplicate (one temp, one real). 
      // Ideally, your list rendering handles duplicates by ID, 
      // or you simply ignore the incoming message if it matches the content/timestamp.
      
    } catch (e) {
      // If sending fails, show error
      emit(ChatError("Failed to send message"));
      // Optional: Remove the temp message from the list here if it failed
      loadMessages(); 
    }
  }

  // 3. Receive Real-time Message (Call this from your SignalR Listener)
  void onMessageReceived(MessageDto message) {
    // Prevent duplicate if the API loaded it and SignalR sent it at the same time
    final isDuplicate = _messages.any((m) => m.id == message.id);
    
    if (!isDuplicate) {
      // Insert at index 0 because ListView is reverse: true
      _messages.insert(0, message);
      emit(ChatLoaded(List.from(_messages))); // Emit NEW list copy
    }
  }
  
}