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
import 'screens/workout_selection_screen.dart'; // Import the new selection screen

void main() => runApp(const FitnessApp());

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
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

  @override
  void initState() {
    super.initState();

    _navManager.addListener(() {
      setState(() {
        int newIndex = _navManager.currentIndex;

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
          // Workout Selection Tab
          _showWeightModal = false;
          _showExerciseModal = false;
          _actualCurrentPage = 3;
        } else if (newIndex == 5) {
          // Notes Tab
          _showWeightModal = false;
          _showExerciseModal = false;
          _actualCurrentPage = 4;
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
    // Dynamic page list ensures selection screen always has the latest manager data
    final List<Widget> dynamicPages = [
      const HomeScreen(),
      AgendaScreen(
        agendaManager: _agendaManager,
        workoutManager: _workoutManager,
        navManager: _navManager,
      ),
      WeightGraphScreen(manager: _weightManager, navManager: _navManager),
      // REPLACED: ActiveWorkoutScreen is now WorkoutSelectionScreen
      WorkoutSelectionScreen(
        agendaManager: _agendaManager,
        workoutManager: _workoutManager,
        navManager: _navManager,
      ),
      NotesScreen(navManager: _navManager, notesManager: _notesManager),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_showWeightModal || _showExerciseModal) {
                setState(() {
                  _showWeightModal = false;
                  _showExerciseModal = false;
                });
              }
            },
            child: dynamicPages[_actualCurrentPage],
          ),

          if (_showWeightModal)
            Align(
              alignment: const Alignment(0, 0.65),
              child: WeightModal(
                manager: _weightManager,
                navManager: _navManager,
              ),
            ),

          if (_showExerciseModal)
            Align(
              alignment: const Alignment(0, 0.68),
              child: ExerciseModal(
                manager: _exerciseManager,
                manager2: _workoutManager,
                navManager: _navManager,
              ),
            ),

          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: _navManager),
          ),
        ],
      ),
    );
  }
}