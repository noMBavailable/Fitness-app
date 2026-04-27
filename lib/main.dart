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

  int _actualCurrentPage = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text("Workout Page")),
    const Center(child: Text("Weight Page Content")),
    const Center(child: Text("Settings Page")),
  ];

  @override
void initState() {
  super.initState();
  _navManager.addListener(() {
    setState(() {
      int newIndex = _navManager.currentIndex;

      // MAKE THIS BETTER

      // 1. Check if the button pressed is a "Modal Button"
      if (newIndex == 2) { 
        _showWeightModal = true;
        _showExerciseModal = false;
        // DO NOT update a local _currentIndex variable here
      } else if (newIndex == 3) {
        _showExerciseModal = true;
        _showWeightModal = false;
      } else {
        // 2. Only change the background page for Home (0) or Workout (1)
        _showWeightModal = false;
        _showExerciseModal = false;
        _actualCurrentPage = newIndex; 
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
            child: _pages[_actualCurrentPage],
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