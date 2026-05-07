import 'exercise_model.dart';

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