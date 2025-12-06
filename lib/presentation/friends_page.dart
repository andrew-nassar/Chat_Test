import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- EXISTING IMPORTS ---
import '../../logic/friends_cubit/friends_cubit.dart';
import '../../logic/friends_cubit/friends_state.dart';
import '../../models/user_model.dart';
import '../../models/pending_request_model.dart';

// --- ✅ NEW IMPORTS (Required for Chat) ---
import '../../logic/conversations_cubit/conversations_cubit.dart';

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
    
    context.read<FriendsCubit>().initScreen();

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
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, 

      appBar: AppBar(
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
          labelColor: Colors.blue.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue.shade700,
          tabs: const [
            Tab(text: "My Friends"),
            Tab(text: "Requests"),
          ],
        ),
      ),
      
      // ✅ WRAP BODY IN BLOC LISTENER (This performs the Navigation)
      body: BlocListener<ConversationsCubit, ConversationsState>(
        listener: (context, state) {
          if (state is ConversationCreated) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Conversation create scucess"), backgroundColor: Colors.green),
            );
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => ChatPage(conversation: state.conversation),
            //   ),
            // );
          }
          if (state is ConversationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocConsumer<FriendsCubit, FriendsState>(
          listener: (context, state) {
            if (state is FriendsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is FriendsLoading) {
               return const Center(child: CircularProgressIndicator());
            }

            if (state is FriendsLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildFriendsList(state.friends),
                  _buildRequestsList(state.pendingRequests),
                ],
              );
            }

            return const Center(child: Text("Something went wrong"));
          },
        ),
      ),
    );
  }

  // --- TAB 1: FRIENDS LIST ---
  Widget _buildFriendsList(List<UserDto> friends) {
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 50 + 20;

    if (friends.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => context.read<FriendsCubit>().loadFriends(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: topPadding),
          children: [
            const SizedBox(height: 50), 
            Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text("No friends yet.", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<FriendsCubit>().loadFriends(),
      child: ListView.builder(
        padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: 20), 
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return _buildFriendTile(friend);
        },
      ),
    );
  }

  // ✅ UPDATED TILE LOGIC
  Widget _buildFriendTile(UserDto friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        
        // 1. Allow tapping the entire row
        onTap: () {
          context.read<ConversationsCubit>().startChat(friend.id);
        },

        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue.shade50,
          child: Text(
            friend.username.isNotEmpty ? friend.username[0].toUpperCase() : "?",
            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(friend.username, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Tap to chat", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        
        // 2. Allow tapping the specific icon
        trailing: IconButton(
          icon: Icon(Icons.chat_bubble_outline, color: Colors.blue.shade600),
          onPressed: () {
            context.read<ConversationsCubit>().startChat(friend.id);
          },
        ),
      ),
    );
  }

  // --- TAB 2: REQUESTS LIST (Unchanged) ---
  Widget _buildRequestsList(List<PendingRequestModel> requests) {
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 50; 

    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => context.read<FriendsCubit>().loadRequests(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: topPadding),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Center(
              child: Column(
                children: [
                  Icon(Icons.mail_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text("No pending requests.", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<FriendsCubit>().loadRequests(),
      child: ListView.builder(
        padding: EdgeInsets.only(top: topPadding + 20, left: 16, right: 16, bottom: 20), 
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          return Card(
             margin: const EdgeInsets.only(bottom: 12),
             elevation: 2,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             child: ListTile(
               leading: const CircleAvatar(child: Icon(Icons.person_add)),
               title: Text(req.senderName, style: const TextStyle(fontWeight: FontWeight.bold)),
               trailing: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.blue.shade600,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                 ),
                 onPressed: () {
                   context.read<FriendsCubit>().acceptRequest(req.requestId);
                 },
                 child: const Text("Accept", style: TextStyle(color: Colors.white)),
               ),
             ),
          );
        },
      ),
    );
  }
}