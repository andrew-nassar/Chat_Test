import 'dart:convert';
import 'package:chat/core/app_config.dart';
import 'package:chat/models/pending_request_model.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  // ⚠️ CHANGE THIS IP to your local IP (e.g., 192.168.1.X) if using a real phone
  // Use 10.0.2.2 if using Android Emulator
  final String baseUrl = AppConfig.baseUrl;

  // --- EXISTING METHODS ---

  Future<List<UserDto>> getSuggestions(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/User/$userId/suggestions?pageNumber=1&pageSize=20'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final result = PagedResult<UserDto>.fromJson(
          json, (data) => UserDto.fromJson(data as Map<String, dynamic>));
      return result.items;
    } else {
      throw Exception("Failed to load suggestions");
    }
  }

  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Friend/send?senderId=$senderId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "receiverId": receiverId,
        "caseType": "string",
        "caseDescription": "string",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send request");
    }
  }

  Future<List<UserDto>> getFriends(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/User/$userId/friends'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserDto.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load friends");
    }
  }

  // --- NEW MERGED METHODS (Converted to http) ---

  Future<List<PendingRequestModel>> getPendingRequests(String userId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/Friend/requests/$userId'), // Matches your C# Controller
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PendingRequestModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load pending requests");
    }
  }

  // Inside UserService
  Future<void> acceptFriendRequest(String userId, String requestId) async {
    final url = Uri.parse('$baseUrl/api/friend/accept?receiverId=$userId');

    final body = jsonEncode({
      "requestId": requestId,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
    print(userId + " ======== " + requestId);
    if (response.statusCode != 200) {
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      throw Exception('Failed to accept');
    }
  }
}
