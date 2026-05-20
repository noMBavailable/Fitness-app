import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for responsive layout checks
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

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE), 
      body: Column(
        children: [
          const CustomHeader(title: "Home"),

          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
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
                            nextWorkoutTitle, 
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
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (hasWorkoutToday) {
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
                                  navManager.setIndex(4);
                                }
                              },
                              style: ElevatedButton.styleFrom(
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
                              onPressed: () => navManager.setIndex(1),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text("Edit agenda"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), 
                    
                    // FITNESS CONTAINER WITH A THICKER BORDER
                    Center(
                      child: Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5), // Subtle background fill
                          borderRadius: BorderRadius.circular(35), // Rounded modern frame
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.6), // Darkened the stroke contrast slightly
                            width: 5, // MODIFIED: Changed from 2 to 5 for a much bolder layout highlight look
                          ),
                        ),
                        child: Icon(
                          Icons.fitness_center_rounded, 
                          size: 140,
                          color: Colors.black.withValues(alpha: 0.8), 
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
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
            ),
          ),
        ],
      ),
    );
  }
}