import 'dart:ui';
import 'package:chat/presentation/widgets/suggestions_shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/suggestions_cubit/suggestions_cubit.dart';
import '../logic/suggestions_cubit/suggestions_state.dart';
import '../../models/user_model.dart';
// import 'widgets/suggestions_shimmer_loading.dart'; // Uncomment if available

class SuggestionsPage extends StatelessWidget {
  const SuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey/blue modern background
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(context),
      body: const SuggestionsView(),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white.withOpacity(0.8),
      centerTitle: false,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: const Text(
        "Find Friends",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w800,
          fontSize: 24,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class SuggestionsView extends StatelessWidget {
  const SuggestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate top padding dynamically (Status Bar + App Bar Height + Extra Buffer)
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight - 20 ;

    return RefreshIndicator(
      onRefresh: () async => context.read<SuggestionsCubit>().refreshSuggestions(),
      color: Colors.black,
      child: BlocBuilder<SuggestionsCubit, SuggestionsState>(
        builder: (context, state) {
          // 1. Loading
          if (state is SuggestionsLoading) {
            return Padding(
              padding: EdgeInsets.only(top: topPadding),
              // child: const Center(child: CircularProgressIndicator()), 
              child: const SuggestionsShimmerLoading(), // Use this if you have it
            );
          }

          // 2. Error
          if (state is SuggestionsError) {
            return _ErrorState(
              message: state.message,
              onRetry: () => context.read<SuggestionsCubit>().loadSuggestions(),
            );
          }

          // 3. Loaded
          if (state is SuggestionsLoaded) {
            if (state.users.isEmpty) {
              return const _EmptyState();
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.users.length,
              padding: EdgeInsets.only(
                top: topPadding, 
                left: 16, 
                right: 16, 
                bottom: 100 // Bottom padding for FAB or Navbar
              ),
              itemBuilder: (context, index) {
                return SuggestionTile(
                  user: state.users[index],
                  onAdd: () {
                    context.read<SuggestionsCubit>().sendFriendRequest(state.users[index].id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Request sent to ${state.users[index].username}"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.black87,
                      ),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// EXTRACTED WIDGET: Suggestion Tile (The User Card)
// -----------------------------------------------------------------------------
class SuggestionTile extends StatelessWidget {
  final UserDto user;
  final VoidCallback onAdd;

  const SuggestionTile({
    super.key,
    required this.user,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Modern Gradient Avatar
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  (user.username.isNotEmpty ? user.username[0] : "?").toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Suggested for you", // Or @username
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Add Button
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Add",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// EXTRACTED WIDGET: Empty State
// -----------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No new suggestions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for more people.",
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// EXTRACTED WIDGET: Error State
// -----------------------------------------------------------------------------
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Something went wrong",
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.grey[800]
              )
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Try Again"),
            )
          ],
        ),
      ),
    );
  }
}