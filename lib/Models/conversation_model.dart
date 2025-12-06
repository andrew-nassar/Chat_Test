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