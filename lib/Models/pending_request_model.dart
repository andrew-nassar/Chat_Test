class PendingRequestModel {
  final String requestId;
  final String senderId;
  final String senderName;
  final String? sentAt;

  PendingRequestModel({
    required this.requestId,
    required this.senderId,
    required this.senderName,
    this.sentAt,
  });

  factory PendingRequestModel.fromJson(Map<String, dynamic> json) {
    return PendingRequestModel(
      requestId: json['requestId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      sentAt: json['sentAt'],
    );
  }
}