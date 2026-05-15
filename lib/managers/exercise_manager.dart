import 'package:flutter/material.dart';
import '../models/exercise_model.dart';

class ExerciseManager extends ChangeNotifier {
  // We initialize the list with premade data instead of leaving it empty
  final List<Exercise> _exercises = [
    Exercise(id: 'pre_1', name: 'Bench Press', reps: 10, weight: 60.0),
    Exercise(id: 'pre_2', name: 'Squats', reps: 8, weight: 80.0),
    Exercise(id: 'pre_3', name: 'Deadlift', reps: 5, weight: 100.0),
    Exercise(id: 'pre_4', name: 'Lat Pulldown', reps: 12, weight: 45.0),
    Exercise(id: 'pre_5', name: 'Shoulder Press', reps: 10, weight: 30.0),
    Exercise(id: 'pre_6', name: 'Bicep Curls', reps: 12, weight: 15.0),
  ];

  List<Exercise> get exercises => _exercises;

  void addExercise(String name, int reps, double weight) {
    _exercises.add(Exercise(
      id: DateTime.now().toString(),
      name: name,
      reps: reps,
      weight: weight,
    ));
    notifyListeners(); 
  }

  void deleteExercise(String id) {
    _exercises.removeWhere((ex) => ex.id == id);
    notifyListeners();
  }

  void updateExercise(String id, String newName, int newReps, double newWeight) {
    int index = _exercises.indexWhere((ex) => ex.id == id);
    if (index != -1) {
      _exercises[index] = Exercise(
        id: id, 
        name: newName, 
        reps: newReps, 
        weight: newWeight
      );
      notifyListeners();
    }
  }
}