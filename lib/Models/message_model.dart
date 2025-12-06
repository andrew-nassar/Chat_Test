class MessageDto {
  final String id;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  MessageDto({
    required this.id,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.isRead,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      id: json['id'],
      senderId: json['senderId'],
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt']),
      isRead: json['isRead'] ?? false,
    );
  }

  // Helper to check if the message belongs to the current user
  bool isMe(String currentUserId) => senderId == currentUserId;
}