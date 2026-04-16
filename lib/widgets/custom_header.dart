import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;

  const CustomHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.settings, size: 30, color: Colors.white),
            onPressed: () => print("Settings pressed"),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              // Note: You can add a custom font family here later
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 30, color: Colors.white),
            onPressed: () => print("Quit pressed"),
          ),
        ],
      ),
    );
  }
}