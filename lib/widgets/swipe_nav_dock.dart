import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Added for web environment checking
import '../managers/nav_manager.dart';

class SwipeNavDock extends StatelessWidget {
  final NavManager manager;

  const SwipeNavDock({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    const Color navBgColor = Color(0xFF1A1A1A); // Fixed dark navigation bar canvas theme color

    return Container(
      height: 75,
      width: double.infinity,
      decoration: BoxDecoration(
        color: navBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2), // Subtle shadow offset casting upward above the bar
          ),
        ],
      ),
      child: Stack(
        children: [
          // LAYER 1: The scrollable nav options row coupled with an edge-fade ShaderMask
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                // Fades out items visually at the absolute 15% edge thresholds of the view track canvas
                stops: [0.0, 0.15, 0.85, 1.0], 
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn, // Combines alpha masks to clip horizontal edge contents cleanly
            child: ListenableBuilder(
              listenable: manager, // Listens to navigation index changes to dynamically redraw tabs
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        // RESPONSIVE CALCULATION: Centers scroll list elements on desktop screens while maintaining flat padding on mobile
                        padding: EdgeInsets.symmetric(
                          horizontal: kIsWeb
                              ? (MediaQuery.of(context).size.width > 600
                                  ? (MediaQuery.of(context).size.width - 450) / 2
                                  : 20)
                              : 20,
                        ),
                        itemCount: manager.items.length,
                        itemBuilder: (context, index) {
                          final item = manager.items[index];
                          return _buildNavItem(
                            context,
                            index,
                            item.icon,
                            item.title,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // LAYER 2: Side arrow indicators to hint at horizontal scroll availability (Mobile only)
          if (!kIsWeb) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white54,
                  size: 14,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white54,
                  size: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- COMPONENT FACTORY BUILDER ---
  
  // Assembles individual specific navigation buttons with structural validation hooks
  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    bool isSelected = manager.currentIndex == index; // Checks active focus status mappings
    
    return GestureDetector(
      onTap: () {
        // 1. Shift root layout navigation pages focus indices settings pointers
        manager.setIndex(index);

        // 2. STACK CORRECTION FIX: If this navigation selection event is triggered while a sub-workspace 
        // view context is active (such as custom editing maps), pop it off immediately to reveal the targeted screen base layout.
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      behavior: HitTestBehavior.opaque, // Expands interaction space parameters across empty element boundaries
      child: SizedBox(
        width: 80, // Fixed horizontal column sizing tracking grid
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.white, // Active buttons illuminate blue
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