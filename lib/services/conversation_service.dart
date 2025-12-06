import 'dart:convert';
import 'package:chat/core/app_config.dart';
import 'package:http/http.dart' as http;
import '../models/conversation_model.dart';

class ConversationService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  final String baseUrl = AppConfig.baseUrl;

  Future<List<ConversationDto>> getConversations(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Conversation/$userId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ConversationDto.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load chats");
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/Conversation/$conversationId'),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to delete chat");
    }
  }

  Future<ConversationDto> startConversation(
      String currentUserId, String targetUserId) async {
    final Uri url = Uri.parse('$baseUrl/Conversation/start').replace(
      queryParameters: {
        'currentUserId': currentUserId,
      },
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "targetUserId": targetUserId,
        }),
      );

      if (response.statusCode == 200) {
        return ConversationDto.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      throw Exception("Error starting conversation: $e");
    }
  }
}
