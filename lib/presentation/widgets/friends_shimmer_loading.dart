import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FriendsShimmerLoading extends StatelessWidget {
  const FriendsShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 8,
        padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 15),
                // Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 140, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 60, height: 12, color: Colors.white),
                    ],
                  ),
                ),
                // Chat Icon Placeholder
                Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}