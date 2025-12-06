import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SuggestionsShimmerLoading extends StatelessWidget {
  const SuggestionsShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    // Shimmer.fromColors wraps the content you want to animate
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,      // The darker grey base
      highlightColor: Colors.grey[100]!, // The lighter moving shine
      child: ListView.builder(
        itemCount: 8, // Show 8 fake items
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                // 1. Fake Avatar Circle
                Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white, 
                    shape: BoxShape.circle
                  ),
                ),
                const SizedBox(width: 15),
                
                // 2. Fake Text Lines
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thick line (Username)
                      Container(width: 120, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      // Thin line (Subtitle)
                      Container(width: 80, height: 12, color: Colors.white),
                    ],
                  ),
                ),

                // 3. Fake Button Rectangle
                Container(
                  width: 80, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}