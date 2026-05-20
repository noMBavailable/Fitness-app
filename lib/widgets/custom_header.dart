import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Imports web detection flag
import 'package:firebase_auth/firebase_auth.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;

  const CustomHeader({
    super.key,
    required this.title,
    this.showBackButton = false, // Defaults to false if not provided
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // PLATFORM PADDING RULE: Adds 32px top spacing on mobile screens to drop below physical notches, 
      // but strips it down to 0px on web browsers where no camera notch exists.
      margin: EdgeInsets.only(top: kIsWeb ? 0 : 32),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.9)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- LEFT SIDE: BACK BUTTON OR EQUAL BALANCE HOLDER ---
          if (showBackButton) 
            IconButton(
              icon: const Icon(
                Icons.arrow_back_sharp,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Navigates backward one screen in the history stack
              },
            )
          else
            // VISUAL CENTER ALIGNMENT TRICK: If no back button is rendered, add an invisible 48px space 
            // matching the exact size of the right logout icon button. This forces the middle title text 
            // to remain perfectly mathematically centered in the Row.
            const SizedBox(width: 48),

          // --- CENTER: PAGE HEADER TITLE ---
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),

          // --- RIGHT SIDE: SYSTEM AUTHENTICATION INTERACTION BUTTON ---
          IconButton(
            icon: const Icon(
              Icons.logout_rounded, 
              size: 28, 
              color: Colors.white
            ),
            onPressed: () async {
              // 1. Gracefully terminate the current session lifecycle inside Firebase Cloud Authentication
              await FirebaseAuth.instance.signOut();

              // 2. STACK CLEANUP: Checks if the application layer has active pushed sub-screens sitting 
              // over your root shell interface (like viewing historical graphs). If true, it collapses 
              // all overlay histories until it hits route index zero (the base screen layout).
              // This instantly ensures that logged-out profile components leave memory without blocking the UI.
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }
}