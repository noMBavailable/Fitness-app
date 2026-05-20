// --- DATA MODEL ---
// Represents a single weightlifting exercise item holding targeted sets specifications metrics.
class Exercise {
  String id;
  String name;
  int reps;
  double weight;

  Exercise({
    required this.id,
    required this.name,
    required this.reps,
    required this.weight,
  });
}