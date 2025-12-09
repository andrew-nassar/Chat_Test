import 'package:chat/logic/conversations_cubit/conversations_cubit.dart';
import 'package:chat/presentation/conversations_page.dart';
import 'package:chat/presentation/global_message_listener.dart';
import 'package:chat/presentation/profile_page.dart';
import 'package:chat/services/conversation_service.dart';
import 'package:chat/services/signalr_service.dart';
import 'package:chat/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../core/app_routes.dart';
import '../logic/friends_cubit/friends_cubit.dart';
import '../logic/suggestions_cubit/suggestions_cubit.dart';
import 'friends_page.dart';
import 'suggestions_page.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    // SAFETY CHECK
    final args = ModalRoute.of(context)?.settings.arguments;
    final userId = args is String ? args : "";

    if (userId.isEmpty) {
      Future.microtask(
          // ignore: use_build_context_synchronously
          () => AppRoutes.nextRemoveUntil(context,AppRoutes.login)
          );
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // ✅ 3. CRITICAL FIX: CONNECT TO SIGNALR
    // We check if the service is already initialized inside initSignalR, 
    // so it is safe to call this in the build method.
    Future.microtask(() {
       context.read<SignalRService>().initSignalR(userId);
    });
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              SuggestionsCubit(UserService(), userId)..loadSuggestions(),
        ),
        BlocProvider(
          create: (context) =>
              FriendsCubit(UserService(), userId)..loadFriends(),
        ),
        BlocProvider(
          create: (context) => ConversationsCubit(ConversationService(), userId)
            ..loadConversations(),
        ),
      ],
     child: const GlobalMessageListener(
        child: _MainScreenContent(), 
      ),
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
  
  final List<Widget> _pages = const [
    ConversationsPage(),
    FriendsPage(),
    SuggestionsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // ✅ 1. SMOOTH PAGE TRANSITION
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500), // Duration of transition
        switchInCurve: Curves.easeOutExpo, // Smooth entry curve
        switchOutCurve: Curves.easeInExpo, // Smooth exit curve
        
        // This builder creates the animation (Fade + Slide Up)
        transitionBuilder: (Widget child, Animation<double> animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.05), // Start 5% down (Slide Up effect)
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        
        // ✅ CRITICAL: The Key ensures Flutter knows the widget changed
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),

      // ✅ 2. FLOATING NAVBAR
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              child: GNav(
                rippleColor: theme.primaryColor.withOpacity(0.1),
                hoverColor: theme.primaryColor.withOpacity(0.1),
                haptic: true,
                tabBorderRadius: 25,
                
                // Navbar Animation Settings
                curve: Curves.easeInOutCubic,
                duration: const Duration(milliseconds: 500),
                gap: 8,
                
                color: Colors.grey[500],
                activeColor: theme.primaryColor,
                iconSize: 24,
                tabBackgroundColor: theme.primaryColor.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                tabs: [
                  GButton(
                    icon: Icons.chat_bubble_outline,
                    text: 'Chats',
                    leading: _selectedIndex == 0
                        ? null
                        : BlocBuilder<ConversationsCubit, ConversationsState>(
                            builder: (context, state) {
                              bool hasUnread = false;
                              if (state is ConversationsLoaded) {
                                hasUnread = state.conversations.isNotEmpty;
                              }
                              return Stack(
                                children: [
                                  const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                                  if (hasUnread)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        height: 8,
                                        width: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                  ),
                  const GButton(icon: Icons.people_outline, text: 'Friends'),
                  const GButton(icon: Icons.explore_outlined, text: 'Discover'),
                  const GButton(icon: Icons.person_outline, text: 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

