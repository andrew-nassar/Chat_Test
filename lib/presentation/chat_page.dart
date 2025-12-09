import 'package:chat/Models/message_model.dart';
import 'package:chat/services/signalr_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/chat_cubit/chat_cubit.dart';
import '../../services/message_service.dart';

class ChatPageArgs {
  final String conversationId;
  final String otherUserName;
  final String currentUserId;
  // Optional: Add avatar URL if you want to show it in the AppBar
  final String? otherUserAvatar; 

  ChatPageArgs({
    required this.conversationId,
    required this.otherUserName,
    required this.currentUserId,
    this.otherUserAvatar,
  });
}

class ChatPage extends StatefulWidget {
  final ChatPageArgs args;

  const ChatPage({super.key, required this.args});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // 1. Controller must be managed by State, not inside build()
  late TextEditingController _textController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        service: MessageService(),
        conversationId: widget.args.conversationId,
        currentUserId: widget.args.currentUserId, 
        signalRService: context.read<SignalRService>(),
      )..loadMessages(),
      child: GestureDetector(
        // Dismiss keyboard when tapping the message list
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFECE5DD),
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // 1. Message List with Error Listener
              Expanded(
                child: BlocConsumer<ChatCubit, ChatState>(
                  listener: (context, state) {
                    if (state is ChatError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ChatLoaded) {
                      if (state.messages.isEmpty) {
                         return Center(child: Text("Say hi to ${widget.args.otherUserName}!", style: TextStyle(color: Colors.grey[600])));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Start from bottom
                        itemCount: state.messages.length,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          return _buildMessageBubble(msg, widget.args.currentUserId);
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),

              // 2. Input Field
              _buildInputArea(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  AppBar _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: Colors.white,
      elevation: 1,
      foregroundColor: Colors.black,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: widget.args.otherUserAvatar != null 
                ? NetworkImage(widget.args.otherUserAvatar!) 
                : null,
            child: widget.args.otherUserAvatar == null 
                ? Text(widget.args.otherUserName[0].toUpperCase(), style: const TextStyle(fontSize: 14))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.args.otherUserName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageDto msg, String currentUserId) {
    final isMe = msg.isMe(currentUserId);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.content,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${msg.sentAt.hour}:${msg.sentAt.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: msg.isRead ? Colors.blue : Colors.grey,
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    // We use a Builder here to get the context that contains the ChatCubit
    // (Since ChatCubit was created inside build, we need a child context to find it)
    return Builder(
      builder: (innerContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Animated Send Button (Only active when text is present is usually better UX, 
              // but keeping it simple here)
              CircleAvatar(
                backgroundColor: const Color(0xFF008069), // WhatsApp Green
                radius: 24,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 22),
                  onPressed: () {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      // Using innerContext to find the Cubit provided above
                      innerContext.read<ChatCubit>().sendMessage(text);
                      _textController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}