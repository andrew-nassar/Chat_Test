import 'dart:convert';
import 'package:chat/core/app_config.dart';
import 'package:http/http.dart' as http;
import '../Models/message_model.dart';

class MessageService {
  final String baseUrl = AppConfig.baseUrl;

  // GET History
  Future<List<MessageDto>> getMessages(String conversationId, int page) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Message/$conversationId/messages?pageNumber=$page&pageSize=20'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MessageDto.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load messages");
    }
  }

  // SEND Message
  Future<MessageDto> sendMessage(String senderId, String conversationId, String content) async {
    final body = {
      "senderId": senderId,
      "conversationId": conversationId,
      "content": content
    };

    final response = await http.post(
      Uri.parse('$baseUrl/Message/send'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return MessageDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to send message");
    }
  }
}