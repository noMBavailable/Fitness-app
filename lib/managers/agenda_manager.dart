import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';

class AgendaManager extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // The "Master Schedule"
  Map<DateTime, List<Workout>> _scheduledWorkouts = {};

  Map<DateTime, List<Workout>> get scheduledWorkouts => _scheduledWorkouts;

  // 1. LOAD FROM FIREBASE
  Future<void> loadScheduledWorkouts() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scheduled_workouts')
          .get();

      Map<DateTime, List<Workout>> loadedData = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final DateTime date = (data['date'] as Timestamp).toDate();
        final dayKey = DateTime(date.year, date.month, date.day);
        
        final List<dynamic> workoutsData = data['workouts'] ?? [];

        List<Workout> workouts = workoutsData.map((w) {
          final List<dynamic> exData = w['exercises'] ?? [];
          return Workout(
            id: w['id'] ?? '',
            name: w['name'] ?? '',
            selectedExercises: exData.map((e) => Exercise(
              id: e['id'] ?? '',
              name: e['name'] ?? '',
              reps: (e['reps'] as num).toInt(),
              weight: (e['weight'] as num).toDouble(),
            )).toList(),
          );
        }).toList();

        loadedData[dayKey] = workouts;
      }

      _scheduledWorkouts = loadedData;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading agenda: $e");
    }
  }

  // 2. ADD / SCHEDULE TO FIREBASE
  Future<void> scheduleWorkout(DateTime date, Workout workout) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final day = DateTime(date.year, date.month, date.day);
    final String docId = "${day.year}-${day.month}-${day.day}";

    // For now, your logic replaces the day with one workout: [workout]
    // We map the workout and its exercises to JSON
    final workoutMap = {
      'id': workout.id,
      'name': workout.name,
      'exercises': workout.selectedExercises.map((e) => {
        'id': e.id,
        'name': e.name,
        'reps': e.reps,
        'weight': e.weight,
      }).toList(),
    };

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scheduled_workouts')
          .doc(docId)
          .set({
        'date': day,
        'workouts': [workoutMap], // Storing as a list for future multi-workout support
      });

      // Update Local
      _scheduledWorkouts[day] = [workout];
      notifyListeners();
    } catch (e) {
      debugPrint("Error scheduling workout: $e");
    }
  }

  // 3. REMOVE FROM FIREBASE
  Future<void> removeWorkoutFromDay(DateTime date, dynamic workout) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final day = DateTime(date.year, date.month, date.day);
    final String docId = "${day.year}-${day.month}-${day.day}";

    try {
      // Local check
      if (_scheduledWorkouts.containsKey(day)) {
        _scheduledWorkouts[day]!.removeWhere((w) => w.id == workout.id);

        if (_scheduledWorkouts[day]!.isEmpty) {
          _scheduledWorkouts.remove(day);
          // Delete document from Firebase if no workouts left for that day
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('scheduled_workouts')
              .doc(docId)
              .delete();
        } else {
          // If you ever support multiple workouts per day, update the array here
          final remaining = _scheduledWorkouts[day]!.map((w) => {
            'id': w.id,
            'name': w.name,
            'exercises': w.selectedExercises.map((e) => {/* exercises json */}).toList(),
          }).toList();
          
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('scheduled_workouts')
              .doc(docId)
              .update({'workouts': remaining});
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error removing workout: $e");
    }
  }

  List<Workout> getWorkoutsForDay(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return _scheduledWorkouts[day] ?? [];
  }
}