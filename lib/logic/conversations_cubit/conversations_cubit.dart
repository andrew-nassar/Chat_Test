import 'package:bloc/bloc.dart';
import 'package:chat/models/conversation_model.dart';
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

// ✅ 1. NEW STATE: Indicates a chat was successfully started/found
class ConversationCreated extends ConversationsState {
  final ConversationDto conversation;
  ConversationCreated(this.conversation);
}

// --- CUBIT ---
class ConversationsCubit extends Cubit<ConversationsState> {
  final ConversationService _service;
  final String currentUserId;

  // We keep a local cache of the list to restore it after navigation events
  List<ConversationDto> _currentList = [];

  ConversationsCubit(this._service, this.currentUserId) : super(ConversationsInitial());

  // 1. LOAD ALL CONVERSATIONS
  Future<void> loadConversations() async {
    try {
      emit(ConversationsLoading());
      final chats = await _service.getConversations(currentUserId);
      _currentList = chats; // Cache the list
      emit(ConversationsLoaded(chats));
    } catch (e) {
      emit(ConversationsError("Failed to load chats"));
    }
  }

  // 2. DELETE CONVERSATION
  Future<void> deleteConversation(String conversationId) async {
    // Optimistic Update: Remove from UI immediately
    final previousList = List<ConversationDto>.from(_currentList);
    final updatedList = _currentList.where((c) => c.id != conversationId).toList();
    
    _currentList = updatedList;
    emit(ConversationsLoaded(updatedList));

    try {
      await _service.deleteConversation(conversationId);
    } catch (e) {
      // Rollback if API fails
      _currentList = previousList;
      emit(ConversationsError("Could not delete."));
      emit(ConversationsLoaded(_currentList));
    }
  }

  // ✅ 3. START CONVERSATION (New Logic)
  Future<void> startChat(String targetUserId) async {
    try {
      // We don't want to show a full screen loading spinner, 
      // but you could emit(ConversationsLoading()) if you wanted to.
      
      final conversation = await _service.startConversation(currentUserId, targetUserId);

      // Emit specific success state so UI can navigate
      emit(ConversationCreated(conversation));

      // After navigation is handled, put the list back on screen
      // We also verify if this new chat needs to be added to our local list
      final exists = _currentList.any((c) => c.id == conversation.id);
      if (!exists) {
        _currentList.insert(0, conversation); // Add to top
      }
      
      emit(ConversationsLoaded(_currentList));
    } catch (e) {
      emit(ConversationsError("Failed to start chat: $e"));
      // Restore list
      emit(ConversationsLoaded(_currentList));
    }
  }
}