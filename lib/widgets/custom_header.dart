import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;

  const CustomHeader({
    super.key,
    required this.title,
    this.showBackButton = false, // default is false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 23),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Show Back Button if enabled, otherwise show invisible balancing space
          if (showBackButton) 
            IconButton(
              icon: const Icon(
                Icons.arrow_back_sharp,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          else
            const SizedBox(width: 48), // Explicit width matching the size of the right button to keep title centered

          // Center: Main Screen Title Text
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),

          // Right Side: Replaced the Settings Button with a Logout Button
          IconButton(
            icon: const Icon(
              Icons.logout_rounded, 
              size: 28, 
              color: Colors.white
            ),
            onPressed: () async {
              // Gracefully sign out the user session from Firebase
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}