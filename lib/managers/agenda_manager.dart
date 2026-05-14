import 'package:flutter/material.dart';
import '../models/workout_model.dart';

class AgendaManager extends ChangeNotifier {
  // The "Master Schedule"
  final Map<DateTime, List<Workout>> _scheduledWorkouts = {};

  Map<DateTime, List<Workout>> get scheduledWorkouts => _scheduledWorkouts;

  // Add a workout to a specific day
  void scheduleWorkout(DateTime date, Workout workout) {
    // Normalize date (set time to 00:00:00) so different times don't break the map
    final day = DateTime(date.year, date.month, date.day);
    
    _scheduledWorkouts[day] = [workout];
    notifyListeners();
  }

  // Get workouts for a specific day
  List<Workout> getWorkoutsForDay(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return _scheduledWorkouts[day] ?? [];
  }

   void removeWorkoutFromDay(DateTime date, dynamic workout) {
  // Normalize the date so it matches your map keys
  DateTime normalizedDate = DateTime(date.year, date.month, date.day);
  
  if (_scheduledWorkouts.containsKey(normalizedDate)) {
    _scheduledWorkouts[normalizedDate]!.remove(workout);
    
    // Clean up empty lists
    if (_scheduledWorkouts[normalizedDate]!.isEmpty) {
      _scheduledWorkouts.remove(normalizedDate);
    }
    
    notifyListeners();
  }
}
}