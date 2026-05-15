import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';

class WorkoutManager extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Premade workouts (Always local)
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

  // 2. Custom Workouts (From Firebase)
  List<Workout> _customWorkouts = [];

  List<Workout> get workouts => [..._premadeWorkouts, ..._customWorkouts];

  // LOAD WORKOUTS FROM FIREBASE
  Future<void> loadWorkouts() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_workouts')
          .get();

      _customWorkouts = snapshot.docs.map((doc) {
        final data = doc.data();
        final List<dynamic> exData = data['exercises'] ?? [];
        
        // Convert the list of maps back into Exercise objects
        List<Exercise> loadedExercises = exData.map((e) => Exercise(
          id: e['id'] ?? '',
          name: e['name'] ?? '',
          reps: (e['reps'] as num).toInt(),
          weight: (e['weight'] as num).toDouble(),
        )).toList();

        return Workout(
          id: doc.id,
          name: data['name'] ?? '',
          selectedExercises: loadedExercises,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading workouts: $e");
    }
  }

  // ADD WORKOUT TO FIREBASE
  Future<void> addWorkout(String name, List<Exercise> exercises) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String workoutId = DateTime.now().millisecondsSinceEpoch.toString();

    // Convert Exercise objects to Maps for Firestore
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

  // DELETE WORKOUT FROM FIREBASE
  Future<void> deleteWorkout(String id) async {
    if (id.startsWith('w_pre_')) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_workouts')
          .doc(id)
          .delete();

      _customWorkouts.removeWhere((w) => w.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting workout: $e");
    }
  }

  void notifyUI() => notifyListeners();
}