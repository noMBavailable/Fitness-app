import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // 2. Import Firebase Auth
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
import 'screens/auth_screen.dart'; // 3. Import your new AuthScreen

void main() async {
  // 4. Initialize Firebase before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      // 5. Use StreamBuilder to switch between Auth and Home automatically
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // If a user exists in the stream, they are logged in
          if (snapshot.hasData) {
            return const FitnessHomeScreen();
          }
          // Otherwise, show the Login/Signup screen
          return const AuthScreen();
        },
      ),
    );
  }
}

class FitnessHomeScreen extends StatefulWidget {
  const FitnessHomeScreen({super.key});

  @override
  State<FitnessHomeScreen> createState() => _FitnessHomeScreenState();
}

// ... (imports remain the same)

class _FitnessHomeScreenState extends State<FitnessHomeScreen> {
  // Use 'late' to ensure they are ready for the dynamicPages list
  late final NavManager _navManager;
  late final WeightManager _weightManager;
  late final ExerciseManager _exerciseManager;
  late final WorkoutManager _workoutManager;
  late final AgendaManager _agendaManager;
  late final NotesManager _notesManager;

  bool _showWeightModal = false;
  bool _showExerciseModal = false;
  int _actualCurrentPage = 0;

  @override
  void initState() {
    super.initState();
    // Initialize Managers
    _navManager = NavManager();
    _weightManager = WeightManager();
    _exerciseManager = ExerciseManager();
    _workoutManager = WorkoutManager();
    _agendaManager = AgendaManager();
    _notesManager = NotesManager();

    _navManager.addListener(() {
      if (!mounted) return;
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
          _showWeightModal = false;
          _showExerciseModal = false;
          _actualCurrentPage = 3;
        } else if (newIndex == 5) {
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
    // Re-build this list inside build to ensure Managers are initialized
    final List<Widget> dynamicPages = [
      const HomeScreen(),
      AgendaScreen(
        agendaManager: _agendaManager,
        workoutManager: _workoutManager,
        navManager: _navManager,
      ),
      WeightGraphScreen(manager: _weightManager, navManager: _navManager),
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
              child: WeightModal(manager: _weightManager, navManager: _navManager),
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