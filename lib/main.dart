import 'package:flutter/material.dart';
import 'managers/nav_manager.dart';
import 'widgets/swipe_nav_dock.dart';

void main() => runApp(const FitnessApp());

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: FitnessHomeScreen());
  }
}

class FitnessHomeScreen extends StatefulWidget {
  @override
  State<FitnessHomeScreen> createState() => _FitnessHomeScreenState();
}

class _FitnessHomeScreenState extends State<FitnessHomeScreen> {
  final NavManager _navManager = NavManager();

  @override
  void initState() {
    super.initState();
    // Listen to the manager
    _navManager.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // The main content
          Center(child: Text("Displaying: ${_navManager.items[_navManager.currentIndex]}")),
          
          // The floating navigation bar near the bottom
          Align(
            alignment: const Alignment(0, 0.85),     // const might need to be removed when the navbar changes
            child: SwipeNavDock(manager: _navManager),
          ),
        ],
      ),
    );
  }
}