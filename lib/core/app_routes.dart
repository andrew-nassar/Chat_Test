import 'package:chat/presentation/SplashScreen.dart';
import 'package:flutter/material.dart';

// Import your screens
import '../presentation/register_screen.dart';
import '../presentation/home_page.dart';
import '../presentation/login_screen.dart'; 

class AppRoutes {
  // 1. Route Names
  static const String splash = '/'; 
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  
  // Optional routes (if accessed directly)
  static const String suggestions = '/suggestions';
  static const String friends = '/friends';
  static const String profile = '/profile';

  // 2. The Route Generator (Replaces the old routes Map)
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _smoothRoute(const SplashScreen(), settings);
      
      case login:
        return _smoothRoute(const LoginScreen(), settings);
        
      case register:
        return _smoothRoute(const RegisterScreen(), settings);
      
      case home:
        // If MainHomeScreen accepts arguments in constructor, handle it here.
        // If it uses ModalRoute.of(context), just passing settings in _smoothRoute is enough.
        return _smoothRoute(const MainHomeScreen(), settings);

      default:
        // Fallback for undefined routes
        return _smoothRoute(const Scaffold(body: Center(child: Text("Route not found"))), settings);
    }
  }

  // --- 3. SMOOTH TRANSITION LOGIC ---
  static PageRouteBuilder _smoothRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings, // Pass settings so arguments (like userId) work
      transitionDuration: const Duration(milliseconds: 400), // Adjust speed here
      reverseTransitionDuration: const Duration(milliseconds: 400),
      
      pageBuilder: (context, animation, secondaryAnimation) => page,
      
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // CURVE: Makes the animation feel natural
        var curve = Curves.easeInOut;
        var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

        // EFFECT: Fade In + Slide Up slightly
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05), // Start slightly below
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // --- NAVIGATION HELPERS (Same as before) ---

  static Future<void> next(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static Future<void> nextReplacement(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }
  
  static Future<void> nextRemoveUntil(BuildContext context, String routeName) {
    return Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }
}