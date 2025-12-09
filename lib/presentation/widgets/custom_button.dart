import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.blueAccent, // Use your app theme color
        ),
        child: isLoading
            ? Lottie.asset(
                'assets/animations/Material wave loading.json', // Your JSON file path
                height: 40, // Adjust height to fit inside the button
                width: 40,
                fit: BoxFit.contain,
                // Optional: If your lottie is black but button is blue, force it to be white:
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(
                      ['**'], // Targets all layers
                      value: Colors.white,
                    ),
                  ],
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18, 
                  color: Colors.white, // Ensure text is white
                  fontWeight: FontWeight.bold
                ),
              ),
      
      ),
    );
  }
}