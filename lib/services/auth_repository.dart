import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_config.dart';

class AuthRepository {
  Future<String> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse(AppConfig.loginEndpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "PhoneNumber": phone,
        "Password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save Token/ID locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', data['id']); // Adjust 'id' based on your C# response
      return data['id'];
    } else {
      throw Exception("Login Failed: ${response.body}");
    }
  }

  Future<String> register(String name, String phone, String password) async {
    final response = await http.post(
      Uri.parse(AppConfig.registerEndpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "phoneNumber": phone,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', data['id']);
      return data['id'];
    } else {
      throw Exception("Registration Failed${response.body}");
    }
  }
}