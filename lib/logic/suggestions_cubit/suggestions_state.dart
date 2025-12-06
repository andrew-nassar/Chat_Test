// --- STATES ---
import 'package:chat/models/user_model.dart';

abstract class SuggestionsState {}
class SuggestionsInitial extends SuggestionsState {}
class SuggestionsLoading extends SuggestionsState {}
class SuggestionsLoaded extends SuggestionsState {
  final List<UserDto> users;
  SuggestionsLoaded(this.users);
}
class SuggestionsError extends SuggestionsState {
  final String message;
  SuggestionsError(this.message);
}