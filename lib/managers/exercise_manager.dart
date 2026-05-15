import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise_model.dart';

class ExerciseManager extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Premade exercises (Always local)
  final List<Exercise> _premadeExercises = [
    Exercise(id: 'pre_1', name: 'Bench Press', reps: 10, weight: 60.0),
    Exercise(id: 'pre_2', name: 'Squats', reps: 8, weight: 80.0),
    Exercise(id: 'pre_3', name: 'Deadlift', reps: 5, weight: 100.0),
    Exercise(id: 'pre_4', name: 'Lat Pulldown', reps: 12, weight: 45.0),
    Exercise(id: 'pre_5', name: 'Shoulder Press', reps: 10, weight: 30.0),
    Exercise(id: 'pre_6', name: 'Bicep Curls', reps: 12, weight: 15.0),
  ];

  // 2. Custom exercises (From Firebase)
  List<Exercise> _customExercises = [];

  // Getter that combines both for your UI
  List<Exercise> get exercises => [..._premadeExercises, ..._customExercises];

  // LOAD DATA FROM FIREBASE (Like loadWeightHistory)
  Future<void> loadExercises() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_exercises')
          .get();

      _customExercises = snapshot.docs.map((doc) {
        final data = doc.data();
        return Exercise(
          id: doc.id,
          name: data['name'] ?? '',
          reps: (data['reps'] as num).toInt(),
          weight: (data['weight'] as num).toDouble(),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading exercises: $e");
    }
  }

  // ADD/SAVE TO FIREBASE (Like addWeight)
  Future<void> addExercise(String name, int reps, double weight) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Use timestamp as ID (or Firestore auto-id)
    final String exerciseId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_exercises')
          .doc(exerciseId)
          .set({
        'name': name,
        'reps': reps,
        'weight': weight,
        'date': DateTime.now(),
      });

      // Update Local List
      _customExercises.add(Exercise(
        id: exerciseId,
        name: name,
        reps: reps,
        weight: weight,
      ));

      notifyListeners();
    } catch (e) {
      debugPrint("Error saving exercise: $e");
    }
  }

  // UPDATE IN FIREBASE
  Future<void> updateExercise(String id, String name, int reps, double weight) async {
    final user = _auth.currentUser;
    if (user == null || id.startsWith('pre_')) return; // Don't edit premade in DB

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_exercises')
          .doc(id)
          .update({
        'name': name,
        'reps': reps,
        'weight': weight,
      });

      // Update Local List
      int index = _customExercises.indexWhere((ex) => ex.id == id);
      if (index != -1) {
        _customExercises[index] = Exercise(id: id, name: name, reps: reps, weight: weight);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating exercise: $e");
    }
  }

  // DELETE FROM FIREBASE
  Future<void> deleteExercise(String id) async {
    final user = _auth.currentUser;
    if (user == null || id.startsWith('pre_')) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_exercises')
          .doc(id)
          .delete();

      _customExercises.removeWhere((ex) => ex.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting exercise: $e");
    }
  }
}