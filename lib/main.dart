import 'package:flutter/material.dart';
import 'managers/nav_manager.dart';
import 'widgets/swipe_nav_dock.dart';
import 'screens/home_screen.dart';
import 'widgets/weight_modal.dart'; 
import 'widgets/exercise_modal.dart'; 

void main() => runApp(const FitnessApp());

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: FitnessHomeScreen(),
    );
  }
}

class FitnessHomeScreen extends StatefulWidget {
  const FitnessHomeScreen({super.key});

  @override
  State<FitnessHomeScreen> createState() => _FitnessHomeScreenState();
}

class _FitnessHomeScreenState extends State<FitnessHomeScreen> {
  final NavManager _navManager = NavManager();
  
  // Removed 'final' to edit these values
  bool _showWeightModal = false;
  bool _showExerciseModal = false;

  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text("Workout Page")),
    const Center(child: Text("Weight Page Content")),
    const Center(child: Text("Settings Page")),
  ];

  @override
  void initState() {
    super.initState();
    
    // Listen to changes in the NavManager
    _navManager.addListener(() {
      setState(() {
        _showWeightModal = false;
        _showExerciseModal = false;

        // If index 2 (Weight) is selected, show the modal
        if (_navManager.currentIndex == 2) {
          _showWeightModal = true;
        } else if(_navManager.currentIndex == 3) {
          // If any other tab is selected, hide the modal
          _showExerciseModal = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // 1. The main content (wrapped in detector to close modal on tap)
          GestureDetector(
            onTap: () {
              if (_showWeightModal) {
                setState(() => _showWeightModal = false);
              }
            },
            child: _pages[_navManager.currentIndex],
          ),

          // 2. THE FLOATING MODAL
          if (_showWeightModal) 
            const Align(
              // Adjust 0.6 horizontally and 0.5 vertically to line up with your button
              alignment: Alignment(0.4, 0.5), 
              child: WeightModal(),
            ),
          if (_showExerciseModal)
            const Align(
              alignment: Alignment(0.4, 0.5),
              child: ExerciseModal(),
            ),
          
          // 3. The floating navigation bar
          Align(
            alignment: const Alignment(0, 0.85),
            child: SwipeNavDock(manager: _navManager),
          ),
        ],
      ),
    );
  }
}