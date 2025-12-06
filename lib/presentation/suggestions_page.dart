import 'dart:ui'; // Required for ImageFilter
import 'package:chat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/suggestions_cubit/suggestions_cubit.dart';
import '../logic/suggestions_cubit/suggestions_state.dart';
import 'widgets/suggestions_shimmer_loading.dart'; // Make sure this path is correct

class SuggestionsPage extends StatelessWidget {
  const SuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: No BlocProvider here. It uses the one from MainHomeScreen.

    return Scaffold(
      backgroundColor: Colors.white,

      // CRITICAL: This allows the list to scroll BEHIND the app bar
      // so the blur effect actually works.
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        elevation: 3,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white.withOpacity(0.9),
        centerTitle: false,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Text(
          "Find Friends",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 26,
            letterSpacing: -0.5,
          ),
        ),
        // Uncomment and customize if you want an action button
        // actions: [
        //   Container(
        //     margin: const EdgeInsets.only(right: 16),
        //     decoration: BoxDecoration(
        //       color: Colors.grey.shade100,
        //       shape: BoxShape.circle,
        //     ),
        //     child: IconButton(
        //       icon: const Icon(Icons.search, color: Colors.black),
        //       onPressed: () {},
        //     ),
        //   ),
        // ],
      ),

      body: const SuggestionsView(),
    );
  }
}

class SuggestionsView extends StatelessWidget {
  const SuggestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Manually refresh data if user pulls down
        await context.read<SuggestionsCubit>().refreshSuggestions();
      },
      child: BlocBuilder<SuggestionsCubit, SuggestionsState>(
        builder: (context, state) {
          // CASE 1: Loading -> Show Shimmer
          if (state is SuggestionsLoading) {
            // Because we used extendBodyBehindAppBar, we need top padding
            // so the shimmer doesn't start hidden under the AppBar
            return const Padding(
              padding: EdgeInsets.only(top: 100.0),
              child: SuggestionsShimmerLoading(),
            );
          }

          // CASE 2: Error
          if (state is SuggestionsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(state.message,
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () =>
                        context.read<SuggestionsCubit>().loadSuggestions(),
                    child: const Text("Try Again"),
                  )
                ],
              ),
            );
          }

          // CASE 3: Loaded Data
          if (state is SuggestionsLoaded) {
            if (state.users.isEmpty) {
              return Center(
                  child: Text("No new suggestions found!",
                      style: TextStyle(color: Colors.grey[600])));
            }

            return ListView.builder(
              // AlwaysScrollable is needed for RefreshIndicator to work on short lists
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.users.length,
              // Add top padding so the first item isn't hidden behind the AppBar
              padding: const EdgeInsets.only(
                  top: 100, left: 16, right: 16, bottom: 16),
              itemBuilder: (context, index) {
                final user = state.users[index];
                return _buildUserCard(context, user);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserDto user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue[100],
            child: Text(
              (user.username.isNotEmpty ? user.username[0] : "?").toUpperCase(),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "@${user.username}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SuggestionsCubit>().sendRequest(user.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Request sent to ${user.username}"),
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Add",
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
