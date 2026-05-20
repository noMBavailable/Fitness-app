import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';

class WorkoutManager extends ChangeNotifier {
  // Instantiates engine entry handles to Firestore database collections and core auth properties
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- WORKOUT COMPLETION LOGIC ---
  DateTime? _lastCompletedDate;

  // Evaluation property verifying if the user has already finished a routine today
  bool get isWorkoutCompletedToday {
    if (_lastCompletedDate == null) return false;
    final now = DateTime.now();
    return _lastCompletedDate!.year == now.year &&
           _lastCompletedDate!.month == now.month &&
           _lastCompletedDate!.day == now.day;
  }

  // Persists a newly completed training timestamp directly to the user's base root metadata profile
  Future<void> markWorkoutAsCompleted() async {
    final user = _auth.currentUser;
    if (user == null) return; // Guard statement ensuring an active user is logged in

    _lastCompletedDate = DateTime.now();
    notifyListeners(); // Force instant UI layout redrawing to highlight active completion streaks

    try {
      // Uses .set with merge rules to auto-create the user document if dealing with a completely raw sign-up account
      await _firestore.collection('users').doc(user.uid).set({
        'lastCompletedDate': Timestamp.fromDate(_lastCompletedDate!),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving completion status: $e");
    }
  }

  // --- EXISTING WORKOUT LOGIC ---

  // Standard immutable structural core workouts template models provided by default to all app profiles
  final List<Workout> _premadeWorkouts = [
    Workout(
      id: 'w_pre_1',
      name: 'Full Body A',
      selectedExercises: [
        Exercise(id: 'e1', name: 'Squats', reps: 8, weight: 80.0),
        Exercise(id: 'e2', name: 'Bench Press', reps: 10, weight: 60.0),
        Exercise(id: 'e3', name: 'Lat Pulldown', reps: 12, weight: 45.0),
      ],
    ),
    Workout(
      id: 'w_pre_2',
      name: 'Push Day (Chest/Shoulders)',
      selectedExercises: [
        Exercise(id: 'e4', name: 'Incline DB Press', reps: 10, weight: 24.0),
        Exercise(id: 'e5', name: 'Shoulder Press', reps: 10, weight: 30.0),
        Exercise(id: 'e6', name: 'Tricep Pushdowns', reps: 15, weight: 20.0),
      ],
    ),
  ];

  // RAM cache list containing user-created custom training splits
  List<Workout> _customWorkouts = [];

  // Unified accessor combining default preset assets alongside personalized routines maps
  List<Workout> get workouts => [..._premadeWorkouts, ..._customWorkouts];

  // Downloads tracking statistics parameters records linked to active accounts from the cloud
  Future<void> loadWorkouts() async {
    final user = _auth.currentUser;
    if (user == null) {
      _clearLocalData(); // Flush cached arrays out of device memory if session returns null paths
      return;
    }

    try {
      // DATA CLEANUP FIX: Instantly flush legacy cache tracking keys out of RAM variables 
      // so multi-user transitions never risk leaking data maps cross-accounts
      _customWorkouts = [];
      _lastCompletedDate = null;

      // 1. Download User metadata records to locate target completion streak values
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null && userDoc.data()!.containsKey('lastCompletedDate')) {
        _lastCompletedDate = (userDoc.data()!['lastCompletedDate'] as Timestamp).toDate();
      }

      // 2. Fetch all unique customized workout document maps attached to this user id identifier
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_workouts')
          .get();

      // De-serialize remote document indices directly back into native model objects
      _customWorkouts = snapshot.docs.map((doc) {
        final data = doc.data();
        final List<dynamic> exData = data['exercises'] ?? [];
        
        List<Exercise> loadedExercises = exData.map((e) => Exercise(
          id: e['id'] ?? '',
          name: e['name'] ?? '',
          reps: (e['reps'] as num?)?.toInt() ?? 0,
          weight: (e['weight'] as num?)?.toDouble() ?? 0.0,
        )).toList();

        return Workout(
          id: doc.id,
          name: data['name'] ?? '',
          selectedExercises: loadedExercises,
        );
      }).toList();

      notifyListeners(); // Refresh active components layout listeners
    } catch (e) {
      debugPrint("Error loading workouts: $e");
    }
  }

  // CREATE: Registers a custom split data schema signature package inside the user's remote cloud profile
  Future<void> addWorkout(String name, List<Exercise> exercises) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String workoutId = DateTime.now().millisecondsSinceEpoch.toString(); // Compile clean target id codes

    // Transform native exercise parameters models into raw primitive maps for Firestore serialization
    final List<Map<String, dynamic>> exerciseMaps = exercises.map((e) => {
      'id': e.id,
      'name': e.name,
      'reps': e.reps,
      'weight': e.weight,
    }).toList();

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_workouts')
          .doc(workoutId)
          .set({
        'name': name,
        'exercises': exerciseMaps,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Maintain snappy execution response by synchronizing local RAM tracking arrays alongside cloud pushes
      _customWorkouts.add(Workout(
        id: workoutId,
        name: name,
        selectedExercises: List.from(exercises),
      ));

      notifyListeners();
    } catch (e) {
      debugPrint("Error saving workout: $e");
    }
  }

  // UPDATE: Overwrites specific matching document parameter keys maps within target index routes
  Future<void> updateWorkout(String id, String name, List<Exercise> exercises) async {
    if (id.startsWith('w_pre_')) return; // Guard rule protecting static app templates configurations from edits

    final user = _auth.currentUser;
    if (user == null) return;

    final List<Map<String, dynamic>> exerciseMaps = exercises.map((e) => {
      'id': e.id,
      'name': e.name,
      'reps': e.reps,
      'weight': e.weight,
    }).toList();

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_workouts')
          .doc(id)
          .update({
        'name': name,
        'exercises': exerciseMaps,
      });

      // Target current item position offset index inside local array cache to update values cleanly
      int index = _customWorkouts.indexWhere((w) => w.id == id);
      if (index != -1) {
        _customWorkouts[index] = Workout(
          id: id,
          name: name,
          selectedExercises: List.from(exercises),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error updating workout: $e");
    }
  }

  // DELETE: Strips a personalized custom routine document out of database paths indexes mapping rules
  Future<void> deleteWorkout(String id) async {
    if (id.startsWith('w_pre_')) return; // Guard rule: Safeguard system preset records from erasure actions

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_workouts')
          .doc(id)
          .delete();

      _customWorkouts.removeWhere((w) => w.id == id); // Evict from active cached tracking memory arrays
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting workout: $e");
    }
  }

  // System context memory wipe method dispatched automatically upon signouts actions
  void _clearLocalData() {
    _customWorkouts = [];
    _lastCompletedDate = null;
    notifyListeners();
  }

  // Direct manual trigger handle force-firing rendering engines updates pipelines routines
  void notifyUI() => notifyListeners();
}