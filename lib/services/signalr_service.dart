import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:chat/core/app_config.dart';
import '../Models/message_model.dart';

class SignalRService {
  HubConnection? _hubConnection;
  
  // Broadcast stream so multiple widgets can listen (Chat Screen + Global Listener)
  final _messageController = StreamController<MessageDto>.broadcast();
  Stream<MessageDto> get messageStream => _messageController.stream;

  // ✅ FIX: Require userId to connect
  Future<void> initSignalR(String userId) async {
    if (_hubConnection?.state == HubConnectionState.Connected) return;

    // ✅ FIX: Pass userId in Query String
    final serverUrl = "http://10.0.2.2:5026/chatHub?userId=$userId";

    _hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl)
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
        _messageController.add(message);
      } catch (e) {
        print("Error parsing message: $e");
      }
    }
  }
}