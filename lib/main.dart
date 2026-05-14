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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FitnessApp());
}

class FitnessApp extends StatefulWidget {
  const FitnessApp({super.key});

  @override
  State<FitnessApp> createState() => _FitnessAppState();
}

class _FitnessAppState extends State<FitnessApp> {
  // Persistence Layer: Managers created here survive Auth refreshes
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
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
  late int _actualCurrentPage;

  @override
  void initState() {
    super.initState();
    
    // SAFE INITIALIZATION: Maps 0-5 NavManager indices to 0-4 Page indices
    _translateIndex(widget.navManager.currentIndex);

    widget.navManager.addListener(_handleNavChange);
  }

  // Internal helper to ensure we never hit a RangeError
  void _translateIndex(int index) {
    if (index == 2) {
      _showWeightModal = true;
      _showExerciseModal = false;
      // Background stays on current or defaults to 0
      _actualCurrentPage = _actualCurrentPage; 
    } else if (index == 3) {
      _showExerciseModal = true;
      _showWeightModal = false;
      _actualCurrentPage = _actualCurrentPage;
    } else {
      _showWeightModal = false;
      _showExerciseModal = false;
      if (index == 4) {
        _actualCurrentPage = 3; // Active Tab -> WorkoutSelectionScreen
      } else if (index == 5) {
        _actualCurrentPage = 4; // Notes Tab -> NotesScreen
      } else {
        _actualCurrentPage = index; // Home (0) or Agenda (1)
      }
    }
  }

  void _handleNavChange() {
    if (!mounted) return;
    setState(() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _translateIndex(widget.navManager.currentIndex);
    });
  }

  @override
  void dispose() {
    widget.navManager.removeListener(_handleNavChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5 Items (Indices 0, 1, 2, 3, 4)
    final List<Widget> dynamicPages = [
      const HomeScreen(),
      AgendaScreen(
        agendaManager: widget.agendaManager,
        workoutManager: widget.workoutManager,
        navManager: widget.navManager,
      ),
      WeightGraphScreen(manager: widget.weightManager, navManager: widget.navManager),
      WorkoutSelectionScreen(
        agendaManager: widget.agendaManager,
        workoutManager: widget.workoutManager,
        navManager: widget.navManager,
      ),
      NotesScreen(navManager: widget.navManager, notesManager: widget.notesManager),
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
            // Guaranteed to be between 0 and 4
            child: dynamicPages[_actualCurrentPage],
          ),
          if (_showWeightModal)
            Align(
              alignment: const Alignment(0, 0.65),
              child: WeightModal(manager: widget.weightManager, navManager: widget.navManager),
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