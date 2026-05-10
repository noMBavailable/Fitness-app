import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../widgets/swipe_nav_dock.dart';
import '../managers/nav_manager.dart';

class NotesScreen extends StatelessWidget {
  final NavManager navManager;

  const NotesScreen({super.key, required this.navManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Match the background color of your main.dart
      backgroundColor: Colors.white, 
      body: Stack(
        children: [
          Column(
            children: [
              // Use the back button if you want, or leave it false for a main tab
              const CustomHeader(
                title: "Notes",
                showBackButton: false, 
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "This is the future notes app",
                    style: TextStyle(
                      color: Colors.grey, 
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // The Navbar (Floating in the exact same spot)
          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: navManager),
          ),
        ],
      ),
    );
  }
}