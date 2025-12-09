import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../models/pending_request_model.dart';
import 'friends_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final UserService _userService;
  final String currentUserId;

  FriendsCubit(this._userService, this.currentUserId) : super(FriendsInitial());

  // --- 1. INITIAL LOAD (Fixes the Race Condition) ---
  Future<void> initScreen() async {
    emit(FriendsLoading());
    try {
      // Fetch both APIs in parallel. This is faster and safer.
      final results = await Future.wait([
        _userService.getFriends(currentUserId),
        _userService.getPendingRequests(currentUserId),
      ]);

      final friends = results[0] as List<UserDto>;
      final requests = results[1] as List<PendingRequestModel>;
      emit(FriendsLoaded(friends: friends, pendingRequests: requests));
    } catch (e) {
      emit(FriendsError("Failed to load connections: $e"));
    }
  }

  // --- 2. Refresh Friends Only (Pull-to-refresh) ---
  Future<void> loadFriends() async {
    try {
      final friends = await _userService.getFriends(currentUserId);
      
      // Keep existing requests, update friends
      if (state is FriendsLoaded) {
        emit((state as FriendsLoaded).copyWith(friends: friends));
      } else {
        emit(FriendsLoaded(friends: friends));
      }
    } catch (e) {
      // Log error but don't crash UI
      print("Error refreshing friends: $e");
    }
  }

  // --- 3. Refresh Requests Only (Pull-to-refresh) ---
  Future<void> loadRequests() async {
    try {
      final requests = await _userService.getPendingRequests(currentUserId);

      // Keep existing friends, update requests
      if (state is FriendsLoaded) {
        emit((state as FriendsLoaded).copyWith(pendingRequests: requests));
      } else {
        emit(FriendsLoaded(pendingRequests: requests));
      }
    } catch (e) {
      print("Error refreshing requests: $e");
    }
  }

  // --- 4. Accept Request ---
  Future<void> acceptRequest(String requestId) async {
    try {
      await _userService.acceptFriendRequest(currentUserId, requestId);
      
      // Reload both lists to sync UI
      // Using initScreen here ensures we get a clean slate
      // or you can manually call loadFriends() and loadRequests()
      await initScreen(); 
      
    } catch (e) {
      emit(FriendsError("Failed to accept request: $e"));
      // Reload to restore state if it failed
      await initScreen();
    }
  }
  
}