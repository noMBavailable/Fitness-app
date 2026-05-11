import 'package:flutter/material.dart';
import '../managers/agenda_manager.dart';
import '../managers/workout_manager.dart';
import '../managers/nav_manager.dart';
import '../models/workout_model.dart';
import '../widgets/custom_header.dart';
import 'active_workout_screen.dart';

class WorkoutSelectionScreen extends StatelessWidget {
  final AgendaManager agendaManager;
  final WorkoutManager workoutManager;
  final NavManager navManager;

  const WorkoutSelectionScreen({
    super.key,
    required this.agendaManager,
    required this.workoutManager,
    required this.navManager,
  });

  @override
  Widget build(BuildContext context) {
    // Check if anything is scheduled for today
    final todayWorkouts = agendaManager.getWorkoutsForDay(DateTime.now());

    return Column(
      children: [
        const CustomHeader(title: "Start Workout"),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // SECTION 1: TODAY'S AGENDA
              const Text("Planned for Today", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (todayWorkouts.isEmpty)
                const Card(child: ListTile(title: Text("Nothing planned for today.")))
              else
                ...todayWorkouts.map((workout) => _buildWorkoutTile(context, workout, isPlanned: true)),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(thickness: 2),
              ),

              // SECTION 2: ALL WORKOUTS
              const Text("All Workouts", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (workoutManager.workouts.isEmpty)
                const Center(child: Text("No workouts created yet."))
              else
                ...workoutManager.workouts.map((workout) => _buildWorkoutTile(context, workout)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutTile(BuildContext context, Workout workout, {bool isPlanned = false}) {
    return Card(
      color: isPlanned ? Colors.blue[50] : Colors.white,
      child: ListTile(
        leading: Icon(Icons.fitness_center, color: isPlanned ? Colors.blue : Colors.black),
        title: Text(workout.name),
        subtitle: Text("${workout.selectedExercises.length} Exercises"),
        trailing: const Icon(Icons.play_arrow),
        onTap: () {
          // Push the screen so the timer starts ONLY now
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActiveWorkoutScreen(
                workout: workout,
                navManager: navManager,
              ),
            ),
          );
        },
      ),
    );
  }
}