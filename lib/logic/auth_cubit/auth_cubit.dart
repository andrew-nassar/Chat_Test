import 'package:chat/core/app_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());
  // NEW FUNCTION: Check if user is already logged in
  Future<void> checkAuthStatus() async {
    // 1. Show loading (optional, but good for Splash)
    emit(AuthLoading()); 

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      AppConfig.userId = userId ;
      await Future.delayed(const Duration(seconds: 2)); // Optional: Fake delay to show logo

      if (userId != null && userId.isNotEmpty) {
        // User found!
        emit(AuthSuccess(userId));
      } else {
        // User not found, go to Login
        emit(AuthInitial()); // Or a specific state like Unauthenticated
      }
    } catch (e) {
      emit(AuthError("Failed to check session"));
    }
  }
  Future<void> login(String phone, String password) async {
    emit(AuthLoading());
    try {
      final userId = await _repository.login(phone, password);
      emit(AuthSuccess(userId));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(String name, String phone, String password) async {
    emit(AuthLoading());
    try {
      final userId = await _repository.register(name, phone, password);
      emit(AuthSuccess(userId));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}