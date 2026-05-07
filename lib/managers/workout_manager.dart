import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';

class WorkoutManager extends ChangeNotifier {
  final List<Workout> _workouts = [];

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