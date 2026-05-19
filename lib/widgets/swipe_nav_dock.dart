import 'package:flutter/material.dart';
import '../managers/nav_manager.dart';

class SwipeNavDock extends StatelessWidget {
  final NavManager manager;

  const SwipeNavDock({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    const Color navBgColor = Color(0xFF1A1A1A);

    return Container(
      height: 75,
      width: double.infinity,
      decoration: BoxDecoration(
        color: navBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 1. The Scrollable Icons with a ShaderMask
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent, 
                  Colors.black, 
                  Colors.black, 
                  Colors.transparent
                ],
                stops: [0.0, 0.15, 0.85, 1.0], // Fades icons out at the edges
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn, // Uses the gradient to "clip" the icons
            child: ListenableBuilder(
              listenable: manager,
              builder: (context, _) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: manager.items.length,
                  itemBuilder: (context, index) {
                    final item = manager.items[index];
                    // PASSED context to the item builder below
                    return _buildNavItem(context, index, item.icon, item.title);
                  },
                );
              },
            ),
          ),

          // 2. Pure Icons (Left and Right Navigation Indicators)
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white54, size: 14),
            ),
          ),

          const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    bool isSelected = manager.currentIndex == index;
    return GestureDetector(
      onTap: () {
        // 1. Change the tab index like normal
        manager.setIndex(index);
        
        // 2. FIX: If this navbar button is pressed inside a pushed full-screen route 
        // (like the Graph screen or Edit screen), close it immediately to reveal the chosen tab!
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.white,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}