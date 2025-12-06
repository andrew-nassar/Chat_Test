import 'package:chat/presentation/SplashScreen.dart';
import 'package:flutter/material.dart';

// Import your screens
import '../presentation/home_page.dart';
import '../presentation/login_screen.dart'; 
// Note: You don't strictly need to import Suggestion/Friends/Profile here 
// because they are children of MainHomeScreen now.

class AppRoutes {
  // 1. Route Names
  static const String login = '/login'; // <--- Added Login
  static const String home = '/home';
  static const String splash = '/'; // Make Splash the default '/'
  // These are optional now since they are tabs inside Home, 
  // but good to keep if you ever want to push them individually.
  static const String suggestions = '/suggestions';
  static const String friends = '/friends';
  static const String profile = '/profile';

  // 2. Route Map
  static Map<String, WidgetBuilder> get routes {
    return {
      // The starting point (Login)
      login: (context) => const LoginScreen(),
      splash: (context) => const SplashScreen(),
      // The main app (Bottom Nav)
      // This receives the 'userId' via ModalRoute settings inside the widget
      home: (context) => const MainHomeScreen(),

      // NOTE: We generally don't put the Tab pages (Suggestions, etc.) here
      // because they require 'userId' in their constructor, which 
      // the routes map cannot easily provide dynamically.
      // They are managed inside MainHomeScreen.
    };
  }

  // --- NAVIGATION HELPERS ---

  /// Navigate to a new screen (Push)
  static Future<void> next(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// Navigate to a new screen and remove the previous one (Replacement)
  /// Example: Login -> Home
  static Future<void> nextReplacement(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }
  
  /// Navigate and remove everything until a specific route (Remove Until)
  /// Example: Logout -> Login
  static Future<void> nextRemoveUntil(BuildContext context, String routeName) {
    return Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }
}