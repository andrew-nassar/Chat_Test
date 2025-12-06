import 'package:chat/Models/message_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/message_service.dart';

// States
abstract class ChatState {}
class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatLoaded extends ChatState {
  final List<MessageDto> messages;
  ChatLoaded(this.messages);
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

  // We keep a local list to easily add new messages without reloading from API
  List<MessageDto> _messages = [];

  ChatCubit({
    required MessageService service,
    required this.conversationId,
    required this.currentUserId,
  }) : _service = service, super(ChatInitial());

  // 1. Load History
  Future<void> loadMessages() async {
    try {
      emit(ChatLoading());
      _messages = await _service.getMessages(conversationId, 1);
      emit(ChatLoaded(List.from(_messages)));
    } catch (e) {
      emit(ChatError("Failed to load chat history"));
    }
  }

  // 2. Send Message (API Call)
  Future<void> sendMessage(String content) async {
    try {
      // Note: We don't manually add to list here IF your SignalR Hub echoes the message back.
      // If SignalR sends "ReceiveMessage" to the sender too, we wait for that event.
      // If not, uncomment the next lines to add optimistically:
      
      /* final tempMsg = MessageDto(id: 'temp', senderId: currentUserId, content: content, sentAt: DateTime.now(), isRead: false);
      _messages.insert(0, tempMsg);
      emit(ChatLoaded(List.from(_messages))); 
      */

      await _service.sendMessage(currentUserId, conversationId, content);
      // Success! SignalR will handle the UI update.
    } catch (e) {
      emit(ChatError("Failed to send"));
    }
  }

  // 3. Receive Real-time Message (Call this from your SignalR Listener)
  void onMessageReceived(MessageDto message) {
    // Add new message to the TOP of the list (because UI is reversed)
    _messages.insert(0, message);
    emit(ChatLoaded(List.from(_messages)));
  }
}