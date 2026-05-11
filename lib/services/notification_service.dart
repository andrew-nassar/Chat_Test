// notification_service.dart
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // ✅ 1. TRACK ACTIVE CHAT
  String? _currentOpenConversationId;

  void setActiveConversationId(String? id) {
    _currentOpenConversationId = id;
    if (id != null) {
      clearConversation(id); // Clear notifications if we enter the chat
    }
  }

  Future<void> init() async {
    // ... (Keep your existing init code here) ...
  }

  final Map<String, List<String>> _pendingMessages = {}; 

  Future<void> showNotification({
  required String title,
  required String body,
  required String conversationId,
  }) async {
    // Block if chat open
    if (_currentOpenConversationId == conversationId) {
      print("🔕 Notification blocked: User is viewing this chat.");
      return;
    }

    _pendingMessages.putIfAbsent(conversationId, () => []);

    // Prevent consecutive duplicates
    final pending = _pendingMessages[conversationId]!;
    if (pending.isEmpty || pending.last != body) {
      pending.add(body);
    }

    final inboxStyle = InboxStyleInformation(
      pending,
      contentTitle: title,
      summaryText: '${pending.length} new messages',
    );

    final androidDetails = AndroidNotificationDetails(
      'chat_channel_id',
      'Chat Messages',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: inboxStyle,
      groupKey: "chat_$conversationId",
    );

    // IMPORTANT: pass an empty body (or a short summary) so the collapsed view
    // doesn't duplicate the first inbox line.
    await _notificationsPlugin.show(
      conversationId.hashCode,
      title,
      '', // <-- empty to avoid duplication
      NotificationDetails(android: androidDetails),
    );
  }


  void clearConversation(String conversationId) {
    _pendingMessages.remove(conversationId);
    _notificationsPlugin.cancel(conversationId.hashCode);
  }
}