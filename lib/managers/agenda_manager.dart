import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';

class AgendaManager extends ChangeNotifier {
  // Instantiates underlying entry points to cloud database nodes and session authentications
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- THE MASTER TIMELINE SCHEDULE ---
  // Maps specific normalized calendar dates to their allocated collection of workout routines
  Map<DateTime, List<Workout>> _scheduledWorkouts = {};

  // Public state accessor exposing calendar mappings to frontend UI components
  Map<DateTime, List<Workout>> get scheduledWorkouts => _scheduledWorkouts;

  // --- 1. DOWNLOAD TIMELINE DATA ---
  // Connects to Firebase to fetch all historical and future calendar planning logs
  Future<void> loadScheduledWorkouts() async {
    final user = _auth.currentUser;
    if (user == null) {
      _clearLocalData(); // Flush cached arrays out of memory if session states return null
      return;
    }

    try {
      // DATA CLEANUP FIX: Instantly empty out RAM tracking cache maps before loading items 
      // to guarantee legacy records never bleed across profile signout transactions
      _scheduledWorkouts = {};

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scheduled_workouts')
          .get();

      Map<DateTime, List<Workout>> loadedData = {};

      // Parse individual daily snapshot containers
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final DateTime date = (data['date'] as Timestamp).toDate();
        
        // Normalize timestamps to exact midnight blocks to ensure perfect structural lookup mapping
        final dayKey = DateTime(date.year, date.month, date.day);
        
        final List<dynamic> workoutsData = data['workouts'] ?? [];

        // De-serialize nested object maps back into native dynamic models matrices
        List<Workout> workouts = workoutsData.map((w) {
          final List<dynamic> exData = w['exercises'] ?? [];
          return Workout(
            id: w['id'] ?? '',
            name: w['name'] ?? '',
            selectedExercises: exData.map((e) => Exercise(
              id: e['id'] ?? '',
              name: e['name'] ?? '',
              reps: (e['reps'] as num?)?.toInt() ?? 0,
              weight: (e['weight'] as num?)?.toDouble() ?? 0.0,
            )).toList(),
          );
        }).toList();

        loadedData[dayKey] = workouts;
      }

      _scheduledWorkouts = loadedData;
      notifyListeners(); // Request framework re-renders across active calendar widgets listeners
    } catch (e) {
      debugPrint("Error loading agenda: $e");
    }
  }

  // --- 2. SCHEDULE ACTION PATHWAY ---
  // Binds a designated workout layout object blueprint onto a specific target calendar grid space
  Future<void> scheduleWorkout(DateTime date, Workout workout) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Standardize time frames to midnight parameters to guarantee uniform index keys mapping
    final day = DateTime(date.year, date.month, date.day);
    final String docId = "${day.year}-${day.month}-${day.day}";

    // Flatten nested layout classes down into serializable data maps matrices structures
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
      // Push document parameters straight to targeted day slots inside the database storage structure
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scheduled_workouts')
          .doc(docId)
          .set({
        'date': day,
        'workouts': [workoutMap], // Stores training maps inside structured array lists fields
      });

      // Mirror push routines inside local RAM arrays to handle instant UI workflow updates safely
      _scheduledWorkouts[day] = [workout];
      notifyListeners();
    } catch (e) {
      debugPrint("Error scheduling workout: $e");
    }
  }

  // --- 3. DISMISS ACTION PATHWAY ---
  // Erases an allocated routine record item out of the chosen calendar timestamp list track
  Future<void> removeWorkoutFromDay(DateTime date, dynamic workout) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final day = DateTime(date.year, date.month, date.day);
    final String docId = "${day.year}-${day.month}-${day.day}";

    try {
      if (_scheduledWorkouts.containsKey(day)) {
        // Evict targeted id elements from local timeline tracking scopes
        _scheduledWorkouts[day]!.removeWhere((w) => w.id == workout.id);

        // Clean-up rule: If no activities remain on that calendar day row, drop the node entirely
        if (_scheduledWorkouts[day]!.isEmpty) {
          _scheduledWorkouts.remove(day);
          
          // Remove document from Cloud collections if empty to save storage space
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('scheduled_workouts')
              .doc(docId)
              .delete();
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error removing workout: $e");
    }
  }

  // --- 4. DATA RETRIEVAL HELPER ---
  // Explicit lookup query parameter tool fetching scheduled events lists for selected target days
  List<Workout> getWorkoutsForDay(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return _scheduledWorkouts[day] ?? [];
  }

  // Local caching clear script executed automatically upon system logout commands
  void _clearLocalData() {
    _scheduledWorkouts = {};
    notifyListeners();
  }
}