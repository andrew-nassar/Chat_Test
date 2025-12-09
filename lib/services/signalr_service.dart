import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:chat/core/app_config.dart'; // Ensure this has your IP/localhost
import '../Models/message_model.dart';

class SignalRService {
  HubConnection? _hubConnection;
  
  // 1. Create a Stream Controller to broadcast messages to the app
  final _messageController = StreamController<MessageDto>.broadcast();
  Stream<MessageDto> get messageStream => _messageController.stream;
  
  // 2. Initialize Connection
  Future<void> initSignalR(String userId) async {
    // If already connected with this user, return
    if (_hubConnection?.state == HubConnectionState.Connected) return;
    
    // ✅ Pass userId in the URL Query String
    final serverUrl = "${AppConfig.baseUrl}/chatHub?userId=$userId";

    _hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl) // No token factory needed for now
        .withAutomaticReconnect()
        .build();

    _hubConnection?.on("ReceiveMessage", _handleIncomingMessage);

    try {
      await _hubConnection?.start();
      print("✅ SignalR Connected for User: $userId");
    } catch (e) {
      print("❌ SignalR Connection Error: $e");
    }
  }

  void _handleIncomingMessage(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      try {
        final data = args[0] as Map<String, dynamic>;
        final message = MessageDto.fromJson(data);
        _messageController.add(message); // Broadcast to listeners
      } catch (e) {
        print("Error parsing message: $e");
      }
    }
  }
}