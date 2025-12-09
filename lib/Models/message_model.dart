class MessageDto {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime sentAt; // Maps to "createdAt"
  final bool isRead;

  // Constructor
  MessageDto({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.isRead,
  });
  
  // 1. Convert JSON from API to Dart Object
  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      // Parse the ISO 8601 string to DateTime
      sentAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  // 2. Convert Dart Object to JSON (For SQLite)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      // Store date as String for SQLite
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead ? 1 : 0, // SQLite uses 0/1 for booleans
    };
  }
  
  // Helper to check if message is mine
  bool isMe(String currentUserId) {
    return senderId == currentUserId;
  }
}