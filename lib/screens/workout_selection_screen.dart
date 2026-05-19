import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
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
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            children: [
              // SECTION 1: TODAY'S AGENDA
              const Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Planned for Today", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              if (todayWorkouts.isEmpty)
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), 
                    side: BorderSide(color: Colors.grey[300]!)
                  ),
                  child: const ListTile(
                    title: Text("Nothing planned for today.", style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ...todayWorkouts.map((workout) => _buildWorkoutTile(context, workout, isPlanned: true)),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 25),
                child: Divider(thickness: 1, height: 1),
              ),

              // SECTION 2: ALL WORKOUTS
              const Row(
                children: [
                  Icon(Icons.format_list_bulleted_rounded, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("All Workouts", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: isPlanned ? const Color(0xFFE3F2FD) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          splashColor: const Color(0xFF00B4DB).withValues(alpha:0.2),
          onTap: () {
            // Provide physical feedback on tap
            HapticFeedback.mediumImpact();

            // Push to ActiveWorkoutScreen and pass the workoutManager
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActiveWorkoutScreen(
                  workout: workout,
                  navManager: navManager,
                  workoutManager: workoutManager, // REQUIRED FIX
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPlanned ? Colors.blue : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fitness_center, 
                    color: isPlanned ? Colors.white : Colors.black87
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "${workout.selectedExercises.length} Exercises",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.blue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}