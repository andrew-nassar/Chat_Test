abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final String userId;
  AuthSuccess(this.userId);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}