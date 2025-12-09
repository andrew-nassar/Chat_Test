import 'dart:ui';
import 'package:chat/core/app_config.dart';
import 'package:chat/models/conversation_model.dart';
import 'package:chat/presentation/chat_page.dart';
import 'package:chat/presentation/widgets/suggestions_shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Logic & Pages
import '../../logic/conversations_cubit/conversations_cubit.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), // Light modern background
      extendBodyBehindAppBar: true, // For the blur effect
      appBar: _buildModernAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ConversationsCubit>().loadConversations();
        },
        color: Colors.black,
        child: BlocBuilder<ConversationsCubit, ConversationsState>(
          builder: (context, state) {
            // Calculate top padding to push content below the blurred AppBar
            final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;

            // 1. Loading
            if (state is ConversationsLoading) {
              return Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: const SuggestionsShimmerLoading(),
              );
            }

            // 2. Error
            if (state is ConversationsError) {
              return _ErrorState(
                message: state.message, 
                onRetry: () => context.read<ConversationsCubit>().loadConversations()
              );
            }

            // 3. Loaded
            if (state is ConversationsLoaded) {
              if (state.conversations.isEmpty) {
                return _EmptyState(topPadding: topPadding);
              }

              return ListView.builder(
                padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: 20),
                itemCount: state.conversations.length,
                itemBuilder: (context, index) {
                  final conversation = state.conversations[index];
                  return ConversationTile(conversation: conversation);
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white.withOpacity(0.85),
      centerTitle: false,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: const Text(
        "Messages",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 26,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_square, color: Colors.black87),
          onPressed: () {
            // Optional: Navigate to "New Chat" screen (Friends Page)
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGET: CONVERSATION TILE
// -----------------------------------------------------------------------------
class ConversationTile extends StatelessWidget {
  final ConversationDto conversation;

  const ConversationTile({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    // 1. Extract Data
    final otherUser = conversation.otherParticipants.isNotEmpty
        ? conversation.otherParticipants.first
        : null;
    final String name = otherUser?.username ?? "Unknown";
    
    // Logic: Handle cases where there are no messages yet
    final bool hasMessage = conversation.lastMessageContent != null && conversation.lastMessageContent!.isNotEmpty;
    final String lastMsg = hasMessage ? conversation.lastMessageContent! : "Start chatting now";
    
    // Logic: If no message time exists, use the conversation creation time or now
    final String time = _formatTime(conversation.lastMessageAt ?? DateTime.now());
    
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

    // 2. Slide to Delete Feature
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        context.read<ConversationsCubit>().deleteConversation(conversation.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$name conversation deleted")),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            // ---------------------------------------------------------
            // KEY CHANGE HERE: Make onTap async and await the return
            // ---------------------------------------------------------
            onTap: () async {
              // 1. Navigate and WAIT until the user comes back
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    args: ChatPageArgs(
                      conversationId: conversation.id,
                      otherUserName: name,
                      otherUserAvatar: null,
                      currentUserId: AppConfig.userId!,
                    ),
                  ),
                ),
              );

              // 2. When they return, refresh the list to show the new message
              if (context.mounted) {
                // Ideally, create a 'silentRefresh()' in your Cubit that doesn't 
                // show the full loading shimmer, but updates the data.
                context.read<ConversationsCubit>().loadConversations();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // A. Avatar
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade300, Colors.indigo.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // B. Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              time,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lastMsg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            // Style changes slightly if it's a placeholder message
                            color: hasMessage ? Colors.grey.shade600 : Colors.indigo.shade300,
                            fontSize: 14,
                            fontStyle: hasMessage ? FontStyle.normal : FontStyle.italic,
                            height: 1.2,
                            fontWeight: hasMessage ? FontWeight.normal : FontWeight.w500, 
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Time Helper
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else if (diff.inDays == 1) {
      return "Yesterday";
    } else {
      return "${time.day}/${time.month}";
    }
  }
}

// -----------------------------------------------------------------------------
// WIDGET: EMPTY STATE
// -----------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final double topPadding;
  const _EmptyState({required this.topPadding});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: topPadding),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.forum_outlined, size: 60, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 24),
              Text(
                "No Messages Yet",
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.grey.shade800
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your conversations will appear here.",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGET: ERROR STATE
// -----------------------------------------------------------------------------
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text("Retry")),
        ],
      ),
    );
  }
}