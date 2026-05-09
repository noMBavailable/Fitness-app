import 'package:flutter/material.dart';
import '../managers/exercise_manager.dart';
import '../managers/workout_manager.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../widgets/custom_header.dart';

class EditWorkoutScreen extends StatefulWidget {
  final ExerciseManager exerciseManager;
  final WorkoutManager workoutManager;

  const EditWorkoutScreen({
    super.key,
    required this.exerciseManager,
    required this.workoutManager,
  });

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final _nameController = TextEditingController();
  List<Exercise> _tempSelected = [];

  // This opens the creation/edit form
  void _showWorkoutForm({Workout? workout}) {
    if (workout != null) {
      _nameController.text = workout.name;
      _tempSelected = List.from(workout.selectedExercises);
    } else {
      _nameController.clear();
      _tempSelected = [];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder( // Needed to update checkboxes inside a modal
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(workout == null ? "New Workout" : "Edit Workout", 
                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Workout Name"),
              ),
              const SizedBox(height: 10),
              const Text("Select Exercises:"),
              SizedBox(
                height: 200, // Fixed height for the selection list
                child: ListView.builder(
                  itemCount: widget.exerciseManager.exercises.length,
                  itemBuilder: (context, index) {
                    final ex = widget.exerciseManager.exercises[index];
                    return CheckboxListTile(
                      title: Text(ex.name),
                      value: _tempSelected.contains(ex),
                      onChanged: (val) {
                        setModalState(() {
                          val! ? _tempSelected.add(ex) : _tempSelected.remove(ex);
                        });
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    if (workout == null) {
                      widget.workoutManager.addWorkout(_nameController.text, _tempSelected);
                    } else {
                      // Note: You'll need an updateWorkout method in your manager!
                      workout.name = _nameController.text;
                      workout.selectedExercises = List.from(_tempSelected);
                      widget.workoutManager.notifyListeners();
                    }
                    Navigator.pop(context);
                    setState(() {}); // Refresh the main list
                  }
                },
                child: const Text("Save Workout"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workouts = widget.workoutManager.workouts;

    return Scaffold(
      appBar: AppBar(title: const Text("My Workouts")),
      // BOTTOM RIGHT BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWorkoutForm(),
        child: const Icon(Icons.add),
      ),
      body: workouts.isEmpty
          ? const Center(child: Text("No workouts created yet."))
          : ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(workout.name),
                  subtitle: Text("${workout.selectedExercises.length} Exercises"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showWorkoutForm(workout: workout),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            widget.workoutManager.deleteWorkout(workout.id);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}