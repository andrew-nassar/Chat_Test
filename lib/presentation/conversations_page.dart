import 'package:chat/models/conversation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/conversations_cubit/conversations_cubit.dart';
import 'chat_page.dart'; // Import your ChatPage

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ConversationsCubit>().loadConversations();
        },
        child: BlocBuilder<ConversationsCubit, ConversationsState>(
          builder: (context, state) {
            // 1. Loading State
            if (state is ConversationsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Loaded State
            if (state is ConversationsLoaded) {
              if (state.conversations.isEmpty) {
                return const Center(child: Text("No conversations yet."));
              }

              return ListView.separated(
                itemCount: state.conversations.length,
                separatorBuilder: (c, i) => Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (context, index) {
                  final conversation = state.conversations[index];
                  return _buildConversationTile(context, conversation);
                },
              );
            }

            // 3. Error State
            if (state is ConversationsError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildConversationTile(BuildContext context, ConversationDto chat) {
    // LOGIC: Find out who we are talking to.
    // The API returns 'otherParticipants'. For 1-on-1, there is only 1 item in this list.
    final otherUser = chat.otherParticipants.isNotEmpty 
        ? chat.otherParticipants.first 
        : null;

    final String name = otherUser?.username ?? "Unknown User";
    // final String? avatarUrl = otherUser?.profilePictureUrl;
    final String lastMsg = chat.lastMessageContent ?? "Sent an attachment";
    final String time = _formatTime(chat.lastMessageAt);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      
      // A. The Avatar
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.blue.shade100,
        // backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child:  Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))
           ,
      ),

      // B. The Name (Andrew, Peter, etc.)
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),

      // C. The Last Message
      subtitle: Text(
        lastMsg,
        maxLines: 1,
        overflow: TextOverflow.ellipsis, // Adds "..." if too long
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),

      // D. The Time (10:30 PM)
      trailing: Text(
        time,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),

      // E. ON CLICK -> GO TO CHAT
      onTap: () {
        // We navigate to the ChatPage and pass the arguments needed to load messages
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              args: ChatPageArgs(
                conversationId: chat.id,
                otherUserName: name,
                currentUserId: context.read<ConversationsCubit>().currentUserId,
              ),
            ),
          ),
        );
      },
    );
  }

  // Simple Helper to format date
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      // If today, return "10:30"
      return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    } else if (diff.inDays == 1) {
      return "Yesterday";
    } else {
      // If older, return date "12/10"
      return "${time.day}/${time.month}";
    }
  }
}