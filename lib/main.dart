import 'package:flutter/material.dart';

// Managers
import 'managers/nav_manager.dart';
import 'managers/weight_manager.dart';

// Widgets & Screens
import 'widgets/swipe_nav_dock.dart';
import 'screens/home_screen.dart';
import 'widgets/weight_modal.dart'; 
import 'widgets/exercise_modal.dart'; 
import 'managers/exercise_manager.dart'; 
import 'managers/workout_manager.dart';
import 'managers/agenda_manager.dart';
import 'screens/agenda_screen.dart';
import 'screens/weight_graph_screen.dart';

void main() => runApp(const FitnessApp());

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: const FitnessHomeScreen(),
    );
  }
}

class FitnessHomeScreen extends StatefulWidget {
  const FitnessHomeScreen({super.key});

  @override
  State<FitnessHomeScreen> createState() => _FitnessHomeScreenState();
}

class _FitnessHomeScreenState extends State<FitnessHomeScreen> {
  // 1. OBJECT INSTANCES (OOP Managers)
  final NavManager _navManager = NavManager();
  final WeightManager _weightManager = WeightManager();
  final ExerciseManager _exerciseManager = ExerciseManager();
  final WorkoutManager _workoutManager = WorkoutManager();
  final AgendaManager _agendaManager = AgendaManager();

  // 2. STATE VARIABLES
  bool _showWeightModal = false;
  bool _showExerciseModal = false;
  int _actualCurrentPage = 0;

  // 3. PAGE LIST // changed from final to late
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const HomeScreen(),
      AgendaScreen(
        agendaManager: _agendaManager, 
        workoutManager: _workoutManager
      ),
      WeightGraphScreen(manager: _weightManager),
      const Center(child: Text("Settings Page")),
    ];

    
    // Listen to changes in the navigation bar
    _navManager.addListener(() {
      setState(() {
        int newIndex = _navManager.currentIndex;

        // Logic: Tabs 2 and 3 trigger modals. 0 and 1 change the actual background screen.
        if (newIndex == 2) { 
          _showWeightModal = true;
          _showExerciseModal = false;
        } else if (newIndex == 3) {
          _showExerciseModal = true;
          _showWeightModal = false;
        } else {
          // Reset modals and switch the background page
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
          // LAYER 1: THE MAIN CONTENT
          // Uses _actualCurrentPage so the background stays put when modals open
          GestureDetector(
            onTap: () {
              if (_showWeightModal || _showExerciseModal) {
                setState(() {
                  _showWeightModal = false;
                  _showExerciseModal = false;
                });
              }
            },
            child: _pages[_actualCurrentPage],
          ),

          // LAYER 2: THE WEIGHT MODAL
          if (_showWeightModal) 
            Align(
              alignment: const Alignment(0.4, 0.5), 
              // No 'const' because _weightManager is a class instance
              child: WeightModal(manager: _weightManager), 
            ),

          // LAYER 3: THE EXERCISE MODAL
          if (_showExerciseModal)
            Align(
              alignment:  const Alignment(0.8, 0.5), // Positioned above the 4th button
              child: ExerciseModal(manager: _exerciseManager, manager2: _workoutManager),
            ),
          
          // LAYER 4: THE FLOATING NAVBAR
          Align(
            alignment: const Alignment(0, 0.85),
            child: SwipeNavDock(manager: _navManager),
          ),
        ],
      ),
    );
  }
}