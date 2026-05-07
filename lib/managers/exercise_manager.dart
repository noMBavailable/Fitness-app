import 'package:flutter/material.dart';
import '../models/exercise_model.dart';

class ExerciseManager extends ChangeNotifier {
  final List<Exercise> _exercises = [];

  List<Exercise> get exercises => _exercises;

  void addExercise(String name, int reps, double weight) {
    _exercises.add(Exercise(
      id: DateTime.now().toString(),
      name: name,
      reps: reps,
      weight: weight,
    ));
    notifyListeners(); // This tells the UI to refresh
  }

  void deleteExercise(String id) {
    _exercises.removeWhere((ex) => ex.id == id);
    notifyListeners();
  }

  void updateExercise(String id, String newName, int newReps, double newWeight) {
    int index = _exercises.indexWhere((ex) => ex.id == id);
    if (index != -1) {
      _exercises[index] = Exercise(id: id, name: newName, reps: newReps, weight: newWeight);
      notifyListeners();
    }
  }
}