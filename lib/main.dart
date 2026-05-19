import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

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
import 'screens/workout_selection_screen.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FitnessApp());
}

class FitnessApp extends StatefulWidget {
  const FitnessApp({super.key});

  @override
  State<FitnessApp> createState() => _FitnessAppState();
}

class _FitnessAppState extends State<FitnessApp> {
  // Persistence Layer: Using late final is fine here as they are initialized in initState
  late final NavManager _navManager;
  late final WeightManager _weightManager;
  late final ExerciseManager _exerciseManager;
  late final WorkoutManager _workoutManager;
  late final AgendaManager _agendaManager;
  late final NotesManager _notesManager;

  @override
  void initState() {
    super.initState();
    _navManager = NavManager();
    _weightManager = WeightManager();
    _exerciseManager = ExerciseManager();
    _workoutManager = WorkoutManager();
    _agendaManager = AgendaManager();
    _notesManager = NotesManager();

    // Force login on startup
    FirebaseAuth.instance.signOut();

    // NEW: Fetch existing weight data from Firebase on startup
    _weightManager.loadWeightHistory();
    _exerciseManager.loadExercises();
    _workoutManager.loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return FitnessHomeScreen(
              navManager: _navManager,
              weightManager: _weightManager,
              exerciseManager: _exerciseManager,
              workoutManager: _workoutManager,
              agendaManager: _agendaManager,
              notesManager: _notesManager,
            );
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

class FitnessHomeScreen extends StatefulWidget {
  final NavManager navManager;
  final WeightManager weightManager;
  final ExerciseManager exerciseManager;
  final WorkoutManager workoutManager;
  final AgendaManager agendaManager;
  final NotesManager notesManager;

  const FitnessHomeScreen({
    super.key,
    required this.navManager,
    required this.weightManager,
    required this.exerciseManager,
    required this.workoutManager,
    required this.agendaManager,
    required this.notesManager,
  });

  @override
  State<FitnessHomeScreen> createState() => _FitnessHomeScreenState();
}

class _FitnessHomeScreenState extends State<FitnessHomeScreen> {
  bool _showWeightModal = false;
  bool _showExerciseModal = false;

  // FIX: Removed 'late' and initialized with 0 to prevent Hot Reload crashes
  int _actualCurrentPage = 0;

  @override
  void initState() {
    super.initState();

    // Initial mapping of indices
    _translateIndex(widget.navManager.currentIndex);

    widget.navManager.addListener(_handleNavChange);
  }

  // Internal helper to ensure we never hit a RangeError or LateInitializationError
  void _translateIndex(int index) {
    setState(() {
      if (index == 2) {
        _showWeightModal = true;
        _showExerciseModal = false;
      } else if (index == 3) {
        _showExerciseModal = true;
        _showWeightModal = false;
      } else {
        _showWeightModal = false;
        _showExerciseModal = false;

        switch (index) {
          case 0:
            _actualCurrentPage = 0; // Home
            break;
          case 1:
            _actualCurrentPage = 1; // Agenda
            break;
          case 4:
            _actualCurrentPage = 3; // WorkoutSelectionScreen
            break;
          case 5:
            _actualCurrentPage = 4; // NotesScreen
            break;
          default:
            _actualCurrentPage = 0; // Safe fallback
        }
      }
    });
  }

  void _handleNavChange() {
    if (!mounted) return;
    _translateIndex(widget.navManager.currentIndex);
  }

  @override
  void dispose() {
    widget.navManager.removeListener(_handleNavChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // dynamicPages (Indices 0, 1, 2, 3, 4)
    final List<Widget> dynamicPages = [
      HomeScreen(
        agendaManager: widget.agendaManager,
        navManager: widget.navManager,
        workoutManager: widget.workoutManager,
      ),
      AgendaScreen(
        agendaManager: widget.agendaManager,
        workoutManager: widget.workoutManager,
        navManager: widget.navManager,
      ),
      WeightGraphScreen(
        manager: widget.weightManager,
        navManager: widget.navManager,
      ),
      WorkoutSelectionScreen(
        agendaManager: widget.agendaManager,
        workoutManager: widget.workoutManager,
        navManager: widget.navManager,
      ),
      NotesScreen(
        navManager: widget.navManager,
        notesManager: widget.notesManager,
      ),
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
                // Synchronize back to match the active background screen index mapping!
                int restoredNavIndex = _actualCurrentPage;
                if (_actualCurrentPage == 3) restoredNavIndex = 4;
                if (_actualCurrentPage == 4) restoredNavIndex = 5;
                widget.navManager.setIndex(restoredNavIndex);
              }
            },
            child: dynamicPages[_actualCurrentPage],
          ),
          if (_showWeightModal)
            Align(
              alignment: const Alignment(0, 0.65),
              child: WeightModal(
                manager: widget.weightManager,
                navManager: widget.navManager,
              ),
            ),
          if (_showExerciseModal)
            Align(
              alignment: const Alignment(0, 0.68),
              child: ExerciseModal(
                manager: widget.exerciseManager,
                manager2: widget.workoutManager,
                navManager: widget.navManager,
              ),
            ),
          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: widget.navManager),
          ),
        ],
      ),
    );
  }
}
