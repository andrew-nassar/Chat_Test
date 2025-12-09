import 'user_model.dart';

class ConversationDto {
  final String id;
  final String? lastMessageContent;
  final DateTime lastMessageAt;
  final List<UserDto> otherParticipants; // The list of people excluding YOU

  ConversationDto({
    required this.id,
    this.lastMessageContent,
    required this.lastMessageAt,
    required this.otherParticipants,
  });
  // ✅ ADD THIS METHOD
  ConversationDto copyWith({
    String? id,
    List<UserDto>? otherParticipants,
    String? lastMessageContent,
    DateTime? lastMessageAt,
  }) {
    return ConversationDto(
      id: id ?? this.id,
      otherParticipants: otherParticipants ?? this.otherParticipants,
      // If null is passed, keep original. If value is passed, update it.
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }
  
  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    return ConversationDto(
      id: json['id'],
      lastMessageContent: json['lastMessageContent'],
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      otherParticipants: (json['otherParticipants'] as List)
          .map((e) => UserDto.fromJson(e))
          .toList(),
    );
  }
}