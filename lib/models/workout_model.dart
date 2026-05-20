import 'exercise_model.dart';

// --- DATA MODEL ---
// Represents a single workout routine profile containing an array of target exercises.
class Workout {
  String id;
  String name;
  List<Exercise> selectedExercises;

  Workout({
    required this.id,
    required this.name,
    required this.selectedExercises,
  });
}