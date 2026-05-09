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
    
    if (_scheduledWorkouts[day] == null) {
      _scheduledWorkouts[day] = [workout];
    } else {
      _scheduledWorkouts[day]!.add(workout);
    }
    notifyListeners();
  }

  // Get workouts for a specific day
  List<Workout> getWorkoutsForDay(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return _scheduledWorkouts[day] ?? [];
  }
}