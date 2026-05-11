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
      if (_messages.isEmpty) emit(ChatLoading()); // Only show loader if empty
      
      final history = await _service.getMessages(conversationId, 1);
      
      // ✅ Update Source of Truth
      _messages = history; 
      emit(ChatLoaded(List.from(_messages)));
    } catch (e) {
      emit(ChatError("Failed to load chat history"));
    }
  }
  
  // 2. SEND MESSAGE (Optimistic Update)
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // A. Create Temp Message
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final tempMessage = MessageDto(
      id: tempId,
      conversationId: conversationId,
      senderId: currentUserId,
      content: content,
      sentAt: DateTime.now(),
      isRead: false,
    );

    // B. UPDATE UI INSTANTLY (Optimistic)
    // ✅ FIX: Update the class-level _messages list first!
    _messages.insert(0, tempMessage);
    emit(ChatLoaded(List.from(_messages)));

    // C. SEND TO SERVER
    try {
      // ✅ NOTE: Ensure your service returns the created MessageDto!
      final realMessage = await _service.sendMessage(
          currentUserId, conversationId, content
      );

      // D. SWAP TEMP ID FOR REAL ID
      final index = _messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        _messages[index] = realMessage; // Replace temp with real
        emit(ChatLoaded(List.from(_messages))); // Update UI with real ID
      }

    } catch (e) {
      print("❌ Send Failed: $e");
      // Optional: Mark message as failed or remove it
      _messages.removeWhere((m) => m.id == tempId);
      emit(ChatLoaded(List.from(_messages))); // Revert UI
      // emit(ChatError("Failed to send")); // Don't wipe the screen with Error state
    }
  }

  // 3. Receive Real-time Message (Call this from your SignalR Listener)
  // Inside ChatCubit

  void onMessageReceived(MessageDto message) {
    // 1. Check if I am the sender
    if (message.senderId == currentUserId) {
        // If I sent this, I already added it optimistically.
        // IGNORE IT to prevent duplicates.
        return; 
    }

    // 2. Existing duplicate check (for other scenarios)
    final isDuplicate = _messages.any((m) => m.id == message.id);
    if (!isDuplicate) {
      _messages.insert(0, message);
      emit(ChatLoaded(List.from(_messages))); 
    }
  }
  
}