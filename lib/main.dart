import 'package:flutter/material.dart';
import 'managers/nav_manager.dart';
import 'widgets/swipe_nav_dock.dart';
import 'screens/home_screen.dart';

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

  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text("Wokrout Page")),
    const Center(child: Text("Willem")),
    const Center(child: Text("Wokroasdasddae")),
  ];

  @override
  void initState() {
    super.initState();
    // Listen to the manager, makes it so the buttons can be pressed and it updates to other button
    _navManager.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // The main content
          _pages[_navManager.currentIndex],
          
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