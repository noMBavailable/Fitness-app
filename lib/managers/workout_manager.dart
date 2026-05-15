import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';

class WorkoutManager extends ChangeNotifier {
  // Initializing with premade workouts
  final List<Workout> _workouts = [
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
    Workout(
      id: 'w_pre_3',
      name: 'Leg Day (Focus Quads)',
      selectedExercises: [
        Exercise(id: 'e7', name: 'Leg Press', reps: 12, weight: 120.0),
        Exercise(id: 'e8', name: 'Leg Extensions', reps: 15, weight: 40.0),
        Exercise(id: 'e9', name: 'Calf Raises', reps: 20, weight: 50.0),
      ],
    ),
  ];

  List<Workout> get workouts => _workouts;

  void addWorkout(String name, List<Exercise> exercises) {
    _workouts.add(Workout(
      id: DateTime.now().toString(),
      name: name,
      selectedExercises: List.from(exercises),
    ));
    notifyListeners();
  }

  void deleteWorkout(String id) {
    _workouts.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  void notifyUI() {
    notifyListeners();
  }
}