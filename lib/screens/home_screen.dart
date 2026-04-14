import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      
      children: [
        // --- CUSTOM HEADER ---
        Container(
          margin: const EdgeInsets.only(top: 50),
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
          decoration: BoxDecoration(
            // Matching your navigation bar style
            color: Colors.black.withValues(alpha:0.7), 
       
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Settings Button
              IconButton(
                icon: const Icon(Icons.settings, size: 30,color: Colors.white),
                onPressed: () => print("Settings pressed"),
              ),
              
              // Title
              const Text(
                "Home", // change font to something more pleasant
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 27, 
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),

              // Quit Button
              IconButton(
                icon: const Icon(Icons.logout, size: 30,color: Colors.white),
                onPressed: () => print("Quit pressed"),
              ),
            ],
          ),
        ),
        // --- MAIN CONTENT ---
      ],
    );
  }
}