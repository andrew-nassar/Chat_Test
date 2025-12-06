import '../../models/user_model.dart';
import '../../models/pending_request_model.dart';

abstract class FriendsState {}

class FriendsInitial extends FriendsState {}
class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<UserDto> friends;
  final List<PendingRequestModel> pendingRequests;

  // We use named parameters with defaults so we can update them independently
  FriendsLoaded({
    this.friends = const [],
    this.pendingRequests = const [],
  });

  // Helper method to update one list while keeping the other
  FriendsLoaded copyWith({
    List<UserDto>? friends,
    List<PendingRequestModel>? pendingRequests,
  }) {
    return FriendsLoaded(
      friends: friends ?? this.friends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
    );
  }
}

class FriendsError extends FriendsState {
  final String message;
  FriendsError(this.message);
}