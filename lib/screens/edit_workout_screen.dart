import 'package:flutter/material.dart';
import '../managers/exercise_manager.dart';
import '../managers/workout_manager.dart';
import '../managers/nav_manager.dart'; 
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../widgets/swipe_nav_dock.dart';
import '../widgets/custom_header.dart';

class EditWorkoutScreen extends StatefulWidget {
  final ExerciseManager exerciseManager;
  final WorkoutManager workoutManager;
  final NavManager navManager;

  const EditWorkoutScreen({
    super.key,
    required this.exerciseManager,
    required this.workoutManager,
    required this.navManager,
  });

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final _nameController = TextEditingController();
  List<Exercise> _tempSelected = [];

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
      builder: (ctx) => StatefulBuilder(
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
                height: 200,
                child: ListView.builder(
                  itemCount: widget.exerciseManager.exercises.length,
                  itemBuilder: (context, index) {
                    final ex = widget.exerciseManager.exercises[index];
                    // Logic to check if exercise is selected by comparing IDs
                    final isSelected = _tempSelected.any((e) => e.id == ex.id);
                    
                    return CheckboxListTile(
                      title: Text(ex.name),
                      value: isSelected,
                      onChanged: (val) {
                        setModalState(() {
                          if (val == true) {
                            _tempSelected.add(ex);
                          } else {
                            _tempSelected.removeWhere((e) => e.id == ex.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isNotEmpty) {
                    if (workout == null) {
                      // Call the async add method
                      await widget.workoutManager.addWorkout(_nameController.text, _tempSelected);
                    } else {
                      // If you implement a Firebase updateWorkout method, call it here
                      workout.name = _nameController.text;
                      workout.selectedExercises = List.from(_tempSelected);
                      widget.workoutManager.notifyUI();
                    }
                    if (mounted) Navigator.pop(context);
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
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          onPressed: () => _showWorkoutForm(),
          child: const Icon(Icons.add),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const CustomHeader(title: "Edit Workouts", showBackButton: true),
              Expanded(
                // FIXED: Use ListenableBuilder to watch for changes in WorkoutManager
                child: ListenableBuilder(
                  listenable: widget.workoutManager,
                  builder: (context, _) {
                    final workouts = widget.workoutManager.workouts;
                    
                    if (workouts.isEmpty) {
                      return const Center(child: Text("No workouts created yet."));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 120),
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
                                  widget.workoutManager.deleteWorkout(workout.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: widget.navManager),
          ),
        ],
      ),
    );
  }
}