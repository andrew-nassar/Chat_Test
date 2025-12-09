import 'package:bloc/bloc.dart';
import 'package:chat/models/conversation_model.dart';
import '../../Models/message_model.dart';
import '../../services/conversation_service.dart';

// --- STATES ---
abstract class ConversationsState {}
class ConversationsInitial extends ConversationsState {}
class ConversationsLoading extends ConversationsState {}
class ConversationsLoaded extends ConversationsState {
  final List<ConversationDto> conversations;
  ConversationsLoaded(this.conversations);
}
class ConversationsError extends ConversationsState {
  final String message;
  ConversationsError(this.message);
}
class ConversationCreated extends ConversationsState {
  final ConversationDto conversation;
  ConversationCreated(this.conversation);
}

// --- CUBIT ---
class ConversationsCubit extends Cubit<ConversationsState> {
  final ConversationService _service;
  final String currentUserId;

  // Local Cache
  List<ConversationDto> _currentList = [];

  ConversationsCubit(this._service, this.currentUserId) : super(ConversationsInitial());

  // 1. LOAD ALL
  Future<void> loadConversations() async {
    try {
      // Only emit loading if we don't have data yet (prevents flickering)
      if (_currentList.isEmpty) emit(ConversationsLoading());
      
      final chats = await _service.getConversations(currentUserId);
      _currentList = chats; 
      emit(ConversationsLoaded(chats));
    } catch (e) {
      emit(ConversationsError("Failed to load chats"));
    }
  }

  // 2. DELETE
  Future<void> deleteConversation(String conversationId) async {
    final previousList = List<ConversationDto>.from(_currentList);
    final updatedList = _currentList.where((c) => c.id != conversationId).toList();
    
    _currentList = updatedList;
    emit(ConversationsLoaded(updatedList));

    try {
      await _service.deleteConversation(conversationId);
    } catch (e) {
      _currentList = previousList;
      emit(ConversationsError("Could not delete."));
      emit(ConversationsLoaded(_currentList));
    }
  }

  // ✅ 3. UPDATE LIST ON NEW MESSAGE (FIXED)
  void updateConversationOnMessage(MessageDto newMessage) {
    print("📥 CUBIT UPDATE: Handling message for Chat ID: ${newMessage.conversationId}");

    // Fix: If list is empty, we must load from server.
    if (_currentList.isEmpty) {
       loadConversations();
       return;
    }

    // 1. Create a copy of the list
    List<ConversationDto> updatedList = List.from(_currentList);

    // 2. Find the chat
    final index = updatedList.indexWhere((c) => c.id == newMessage.conversationId);

    if (index != -1) {
      // A. Existing Chat: Update & Move to Top
      var conversation = updatedList.removeAt(index);
      
      conversation = conversation.copyWith(
        lastMessageContent: newMessage.content,
        lastMessageAt: newMessage.sentAt,
      );

      updatedList.insert(0, conversation);
      print("✅ Chat moved to top: ${conversation.lastMessageContent}");

    } else {
      // B. New Chat: We don't have user details locally, so we must reload
      print("⚠️ New chat detected. Reloading list from server...");
      loadConversations();
      return; 
    }

    // 3. Update Cache & Emit
    _currentList = updatedList;
    emit(ConversationsLoaded(updatedList));
  }

  // 4. START CHAT
  Future<void> startChat(String targetUserId) async {
    try {
      final conversation = await _service.startConversation(currentUserId, targetUserId);
      emit(ConversationCreated(conversation));

      // Add to list if not exists
      final exists = _currentList.any((c) => c.id == conversation.id);
      if (!exists) {
        _currentList.insert(0, conversation);
      }
      emit(ConversationsLoaded(_currentList));
    } catch (e) {
      emit(ConversationsError("Failed to start chat: $e"));
      emit(ConversationsLoaded(_currentList));
    }
  }
}