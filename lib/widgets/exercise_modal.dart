import 'package:flutter/material.dart';
import '../screens/edit_workout_screen.dart';   
import '../screens/exercise_creation_screen.dart';
import '../managers/exercise_manager.dart';
import '../managers/workout_manager.dart';
import "../managers/nav_manager.dart";

class ExerciseModal extends StatelessWidget {
  final ExerciseManager manager;
  final WorkoutManager manager2;
  final NavManager navManager;

  const ExerciseModal({super.key, required this.manager, required this.manager2, required this.navManager});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Hugs card contents tightly down the vertical line layout
      children: [
        // --- OVERLAY CONTAINER INTERFACE PANEL ---
        Container(
          width: 220, // Strict design width constraint mirroring the Weight modal configuration
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
              
              // Option 1: Launches standalone workout template modifications workspace pages
              ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.black),
                title: const Text("Edit Workout"),
                onTap: () {
                  // Push operation shifts the navigation viewport track forward into EditWorkoutScreen layers
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditWorkoutScreen(
                        workoutManager: manager2, 
                        exerciseManager: manager, 
                        navManager: navManager,
                      ),
                    ),
                  );
                },
              ),
              
              const Divider(),

              // Option 2: Launches individual specific dynamic exercise metadata asset registers
              ListTile(
                leading: const Icon(Icons.list, color: Colors.black),
                title: const Text("Edit Exercise"),
                onTap: () {
                  // Push operation shifts view targets straight into exercise customization builders views
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseCreationScreen(
                        manager: manager, 
                        navManager: navManager,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        // Visual indicator arrow pointing downward directly into the central bottom tracking docks bar anchors
        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 30),
      ],
    );
  }
}