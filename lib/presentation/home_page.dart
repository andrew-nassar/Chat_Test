import 'package:chat/core/app_config.dart';
import 'package:chat/logic/conversations_cubit/conversations_cubit.dart';
import 'package:chat/presentation/conversations_page.dart';
import 'package:chat/services/conversation_service.dart';
import 'package:chat/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_routes.dart';
import '../logic/friends_cubit/friends_cubit.dart';
import '../logic/suggestions_cubit/suggestions_cubit.dart';
import 'friends_page.dart';
import 'suggestions_page.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SAFETY CHECK: Handle null arguments during Hot Restart or dev testing
    final args = ModalRoute.of(context)?.settings.arguments;
    final userId = args is String ? args : "";

    if (userId.isEmpty) {
      // If we lost the ID, force user back to Login to prevent crashes
      Future.microtask(
          () => Navigator.pushReplacementNamed(context, AppRoutes.login));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiBlocProvider(
      providers: [
        // 1. Suggestions
        BlocProvider(
          create: (context) =>
              SuggestionsCubit(UserService(), userId)..loadSuggestions(),
        ),
        // 2. Friends
        BlocProvider(
          create: (context) =>
              FriendsCubit(UserService(), userId)..loadFriends(),
        ),
        // 3. Conversations
        BlocProvider(
          create: (context) => ConversationsCubit(ConversationService(), userId)
            ..loadConversations(),
        ),
      ],
      child: const _MainScreenContent(),
    );
  }
}

class _MainScreenContent extends StatefulWidget {
  const _MainScreenContent();

  @override
  State<_MainScreenContent> createState() => _MainScreenContentState();
}

class _MainScreenContentState extends State<_MainScreenContent> {
  int _selectedIndex = 0;

  // REORDERED LIST: Conversations is First (Standard for Chat Apps)
  final List<Widget> _pages = const [
    ConversationsPage(), // Index 0
    FriendsPage(), // Index 1
    SuggestionsPage(), // Index 2
    ProfilePage(), // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps the state of pages alive (Scroll position, text inputs)
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: [
          // 1. MESSAGES TAB (With Badge)
          NavigationDestination(
            // We use BlocBuilder to dynamically show the unread count/badge
            icon: BlocBuilder<ConversationsCubit, ConversationsState>(
              builder: (context, state) {
                // Logic: If we have conversations, show a dot or number
                // Real implementation: check 'unreadCount' in your model
                bool hasUnread = false;
                if (state is ConversationsLoaded &&
                    state.conversations.isNotEmpty) {
                  // Example logic: hasUnread = state.conversations.any((c) => c.hasUnread);
                  hasUnread = true; // Placeholder
                }

                return Badge(
                  isLabelVisible: hasUnread,
                  label: const Text('!'), // Or number
                  child: const Icon(Icons.chat_bubble_outline),
                );
              },
            ),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: 'Chats',
          ),

          // 2. FRIENDS TAB
          const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Friends',
          ),

          // 3. SUGGESTIONS TAB
          const NavigationDestination(
            icon: Icon(Icons.person_add_outlined),
            selectedIcon: Icon(Icons.person_add),
            label: 'Find',
          ),

          // 4. PROFILE TAB
          const NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PROFILE PAGE (Added basic Logout Logic)
// ---------------------------------------------------------------------------

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            const Text("User Name",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                // Clear preferences, tokens, etc.
                // Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);

                // 1. افتح SharedPreferences
                final prefs = await SharedPreferences.getInstance();

                // 2. امسح كل البيانات
                await prefs.clear();

                // 3. امسح الـ AppConfig لو بتخزّن فيه userId
                AppConfig.userId = null;
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red,
              ),
            )
          ],
        ),
      ),
    );
  }
}
