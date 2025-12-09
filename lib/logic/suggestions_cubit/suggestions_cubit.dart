import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/user_service.dart';
import 'suggestions_state.dart';

// --- CUBIT ---
class SuggestionsCubit extends Cubit<SuggestionsState> {
  final UserService _userService;
  final String currentUserId;

  SuggestionsCubit(this._userService, this.currentUserId) : super(SuggestionsInitial());

  // 1. Fetch Users
  void loadSuggestions() async {
    try {
      emit(SuggestionsLoading());
      final users = await _userService.getSuggestions(currentUserId);
      emit(SuggestionsLoaded(users));
    } catch (e) {
      emit(SuggestionsError("Could not load users."));
    }
  }
  // 2. NEW: Force Refresh (for Pull-to-Refresh)
  Future<void> refreshSuggestions() async {
    try {
      // We don't emit Loading() here to keep the current list visible while updating
      // or you can emit it if you want the spinner.
      final users = await _userService.getSuggestions(currentUserId);
      emit(SuggestionsLoaded(users));
    } catch (e) {
      emit(SuggestionsError("Failed to refresh."));
    }
  }
  // 2. Send Request (and remove user from list optimistically)
  void sendFriendRequest(String receiverId) async {
    if (state is SuggestionsLoaded) {
      final currentList = (state as SuggestionsLoaded).users;
      
      try {
        // Optimistic Update: Remove user immediately from UI so it feels fast
        final updatedList = currentList.where((u) => u.id != receiverId).toList();
        emit(SuggestionsLoaded(updatedList));

        // Call API in background
        await _userService.sendFriendRequest(currentUserId, receiverId);
      } catch (e) {
        // If API fails, put the user back (Rollback)
        emit(SuggestionsError("Failed to add friend."));
        loadSuggestions(); // Reload list to be safe
      }
    }
  }
}