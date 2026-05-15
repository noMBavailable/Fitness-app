import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../managers/agenda_manager.dart';
import '../managers/nav_manager.dart';
import '../screens/active_workout_screen.dart';
import '../managers/workout_manager.dart';

class HomeScreen extends StatelessWidget {
  final AgendaManager agendaManager;
  final NavManager navManager;
  final WorkoutManager workoutManager;

  const HomeScreen({
    super.key, 
    required this.agendaManager, 
    required this.navManager,
    required this.workoutManager,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Check for today's workout
    final todayWorkouts = agendaManager.getWorkoutsForDay(DateTime.now());
    final bool hasWorkoutToday = todayWorkouts.isNotEmpty;
    final String nextWorkoutTitle = hasWorkoutToday ? todayWorkouts.first.name : "None scheduled";

    return Column(
      children: [
        const CustomHeader(title: "Home"),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Next workout",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      nextWorkoutTitle, // Shows the name of today's workout
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Workout button
                      ElevatedButton(
                        onPressed: () {
                          if (hasWorkoutToday) {
                            // Launch the active workout screen with today's workout
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActiveWorkoutScreen(
                                  workout: todayWorkouts.first,
                                  navManager: navManager,
                                  workoutManager: workoutManager,
                                ),
                              ),
                            );
                          } else {
                            // If nothing is planned, jump to the Workout Selection tab
                            navManager.setIndex(4);
                          }
                        },
                        style: ElevatedButton.styleFrom( // Changed to ElevatedButton style for consistency
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(hasWorkoutToday ? "Start workout" : "Choose workout"),
                      ),
                      const SizedBox(width: 20),

                      ElevatedButton(
                        onPressed: () => navManager.setIndex(1), // Jumps to Agenda
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Edit agenda"), // Renamed to reflect action
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40), 
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(45), 
                  ),
                  child: const Icon(
                    Icons.people_alt,
                    size: 150,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Time to crush it!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}