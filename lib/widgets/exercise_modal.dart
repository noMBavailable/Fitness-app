import 'package:flutter/material.dart';
import '../screens/edit_workout_screen.dart';   
import '../screens/exercise_creation_screen.dart';
import '../managers/exercise_manager.dart';
class ExerciseModal extends StatelessWidget {

  final ExerciseManager manager;

  const ExerciseModal({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Column(
            children: [
              const Text("Edit Options", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              // Option 1: Edit Workout
              ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.black),
                title: const Text("Edit Workout"),
                onTap: () {
                  // Navigator.push moves to the new screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditWorkoutScreen()),
                  );
                },
              ),
              
              const Divider(),

              // Option 2: Edit Exercise
              ListTile(
                leading: const Icon(Icons.list, color: Colors.black),
                title: const Text("Edit Exercise"),
                onTap: () {
                  // Navigator.push moves to the new screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ExerciseCreationScreen(manager: manager)),
                  );
                },
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 30),
      ],
    );
  }
}