import 'package:flutter/material.dart';
import '../managers/nav_manager.dart';

class SwipeNavDock extends StatelessWidget {
  final NavManager manager;

  const SwipeNavDock({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(20), // Leaves "room" around the bar
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        // borderRadius: BorderRadius.circular(30),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: List.generate(manager.items.length, (index) {
            bool isSelected = manager.currentIndex == index;
            return GestureDetector(
              onTap: () => manager.setIndex(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  manager.items[index].icon,
                  color: isSelected ? Colors.white : Colors.grey[400],
                  size: 28,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}