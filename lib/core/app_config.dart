class AppConfig {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator/Web
  static const String baseUrl = "http://10.0.2.2:5026/api"; 
  
  static const String loginEndpoint = "$baseUrl/Account/login";
  static const String registerEndpoint = "$baseUrl/Account/register";
  
  static String? userId ;
  // You can add colors or other static data here too
  static const String appName = "Chat App";
}