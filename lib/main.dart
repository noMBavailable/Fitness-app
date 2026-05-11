import 'package:flutter/material.dart';

// Managers
import 'managers/nav_manager.dart';
import 'managers/weight_manager.dart';
import 'managers/exercise_manager.dart';
import 'managers/workout_manager.dart';
import 'managers/agenda_manager.dart';
import 'managers/notes_manager.dart';

// Widgets & Screens
import 'widgets/swipe_nav_dock.dart';
import 'screens/home_screen.dart';
import 'screens/agenda_screen.dart';
import 'screens/weight_graph_screen.dart';
import 'widgets/weight_modal.dart';
import 'widgets/exercise_modal.dart';
import 'screens/notes_screen.dart';

void main() => runApp(const FitnessApp());

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, 
        primarySwatch: Colors.blue,
      ),
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
  // 1. OBJECT INSTANCES
  final NavManager _navManager = NavManager();
  final WeightManager _weightManager = WeightManager();
  final ExerciseManager _exerciseManager = ExerciseManager();
  final WorkoutManager _workoutManager = WorkoutManager();
  final AgendaManager _agendaManager = AgendaManager();
  final NotesManager _notesManager = NotesManager();
 

  // 2. STATE VARIABLES
  bool _showWeightModal = false;
  bool _showExerciseModal = false;
  int _actualCurrentPage = 0;

  // 3. PAGE LIST
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Passing _navManager here fixes the 'missing_required_argument' error
    _pages = [
      const HomeScreen(),
      AgendaScreen(
        agendaManager: _agendaManager,
        workoutManager: _workoutManager, // why is this here? ‼️
        navManager: _navManager, // Pass navManager to AgendaScreen
      ),
      WeightGraphScreen(
        manager: _weightManager, 
        navManager: _navManager, // Fixed: passing required navManager
      ),
      NotesScreen(
        navManager: _navManager,
        notesManager: _notesManager, // Add this line to pass the NotesManager instance
      ), // Uncomment when NotesScreen is ready 
    ];

    // Listen to changes in the navigation bar
    _navManager.addListener(() {
      setState(() {
        int newIndex = _navManager.currentIndex;

        // If we are on a "Pushed" screen (like Graph), 
        // clicking a nav item should bring us back to the main stack
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (newIndex == 2) {
          _showWeightModal = true;
          _showExerciseModal = false;
        } else if (newIndex == 3) {
          _showExerciseModal = true;
          _showWeightModal = false;
        } else if (newIndex == 4) {
          _showWeightModal = false;
          _showExerciseModal = false;
          _actualCurrentPage = 3; // was newIndex
        } else {
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
              alignment: const Alignment(0, 0.65),
              child: WeightModal(
                manager: _weightManager, 
                navManager: _navManager, // Passed to allow Navigator.push
              ),
            ),

          // LAYER 3: THE EXERCISE MODAL
          if (_showExerciseModal)
            Align(
              alignment: const Alignment(0, 0.68),
              child: ExerciseModal(
                manager: _exerciseManager,
                manager2: _workoutManager,
                navManager: _navManager, // Passed to allow Navigator.push
                // navManager: _navManager, // Add this if ExerciseModal needs it too
              ),
            ),

          // LAYER 4: THE GLOBAL FLOATING NAVBAR
          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: _navManager),
          ),
        ],
      ),
    );
  }
}