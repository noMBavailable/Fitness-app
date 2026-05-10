import 'package:flutter/material.dart';
import '../managers/nav_manager.dart';

class SwipeNavDock extends StatelessWidget {
  final NavManager manager;

  const SwipeNavDock({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        // TEST COLOR: Changed from semi-transparent black to solid Red
        color:  Color.fromARGB(255, 75, 75, 75),
        // If you want it rounded again, uncomment the next line:
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
                  // When selected, we'll keep blue for now so you can see the contrast
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  manager.items[index].icon,
                  color: isSelected ? Colors.white : Colors.white70,
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