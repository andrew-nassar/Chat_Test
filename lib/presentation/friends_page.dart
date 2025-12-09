import 'dart:ui';
import 'package:chat/presentation/widgets/friends_shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Logic
import '../../logic/friends_cubit/friends_cubit.dart';
import '../../logic/friends_cubit/friends_state.dart';
import '../../logic/conversations_cubit/conversations_cubit.dart';

// Models
import '../../models/user_model.dart';
import '../../models/pending_request_model.dart';

// Pages

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initial Load
    context.read<FriendsCubit>().initScreen();

    // Lazy load requests tab
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        context.read<FriendsCubit>().loadRequests();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), // Light modern grey
      extendBodyBehindAppBar: true, 

      appBar: _buildModernAppBar(),
      
      // Navigation Listener
      body: BlocListener<ConversationsCubit, ConversationsState>(
        listener: (context, state) {
          if (state is ConversationCreated) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                 content: Text("Opening chat..."), 
                 backgroundColor: Colors.black87,
                 behavior: SnackBarBehavior.floating,
                 duration: Duration(seconds: 1),
               ),
             );
             // Navigate to Chat
            //  Navigator.push(
            //    context,
            //    MaterialPageRoute(
            //      builder: (_) => ChatPage(conversation: state.conversation),
            //    ),
            //  );
          }
          if (state is ConversationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        // Data Consumer
        child: BlocConsumer<FriendsCubit, FriendsState>(
          listener: (context, state) {
            if (state is FriendsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            // Calculate padding once
            final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight -20 ;

            if (state is FriendsLoading) {
               return const Padding(
                padding: EdgeInsets.only(top: 20),
                 child: FriendsShimmerLoading(),
               );
            }

            if (state is FriendsLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildFriendsList(state.friends, topPadding),
                  _buildRequestsList(state.pendingRequests, topPadding),
                ],
              );
            }

            return const Center(child: Text("Something went wrong"));
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
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
        "Connections",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 26,
          letterSpacing: -0.5,
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.black,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: "My Friends"),
          Tab(text: "Requests"),
        ],
      ),
    );
  }

  // --- TAB 1: FRIENDS LIST ---
  Widget _buildFriendsList(List<UserDto> friends, double topPadding) {
    if (friends.isEmpty) {
      return _EmptyState(
        icon: Icons.people_outline,
        message: "No friends yet",
        subMessage: "Start adding people to chat!",
        topPadding: topPadding,
        onRefresh: () => context.read<FriendsCubit>().loadFriends(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<FriendsCubit>().loadFriends(),
      color: Colors.black,
      child: ListView.builder(
        padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: 20), 
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return FriendContactTile(user: friend);
        },
      ),
    );
  }

  // --- TAB 2: REQUESTS LIST ---
  Widget _buildRequestsList(List<PendingRequestModel> requests, double topPadding) {
    if (requests.isEmpty) {
      return _EmptyState(
        icon: Icons.mail_outline,
        message: "No pending requests",
        subMessage: "Check back later.",
        topPadding: topPadding,
        onRefresh: () => context.read<FriendsCubit>().loadRequests(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<FriendsCubit>().loadRequests(),
      color: Colors.black,
      child: ListView.builder(
        padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: 20), 
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          return FriendRequestTile(request: req);
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGET: FRIEND TILE (Cleaned Up)
// -----------------------------------------------------------------------------
class FriendContactTile extends StatelessWidget {
  final UserDto user;
  
  const FriendContactTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          onTap: () {
             context.read<ConversationsCubit>().startChat(user.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Avatar
                Container(
                  height: 50, width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade300, Colors.blue.shade600],
                      begin: Alignment.topLeft, end: Alignment.bottomRight
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user.username.isNotEmpty ? user.username[0].toUpperCase() : "?",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                
                const SizedBox(width: 15),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Tap to chat", 
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)
                      ),
                    ],
                  ),
                ),

                // Chat Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle
                  ),
                  child: Icon(Icons.chat_bubble_rounded, color: Colors.blue.shade600, size: 20),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGET: REQUEST TILE (Cleaned Up)
// -----------------------------------------------------------------------------
class FriendRequestTile extends StatelessWidget {
  final PendingRequestModel request;

  const FriendRequestTile({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.orange.shade100,
            child: Icon(Icons.person_add, color: Colors.orange.shade700),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.senderName, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                Text(
                   request.sentAt ?? "Recently",
                   style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              context.read<FriendsCubit>().acceptRequest(request.requestId);
            },
            child: const Text("Accept", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGET: EMPTY STATE (Reusable)
// -----------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subMessage;
  final double topPadding;
  final Future<void> Function() onRefresh;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subMessage,
    required this.topPadding,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.black,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: topPadding),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 60, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 20),
                Text(
                  message, 
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 5),
                Text(
                  subMessage, 
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}