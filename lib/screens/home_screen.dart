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
    // 1. Fetch scheduled routines for the current calendar timestamp day
    final todayWorkouts = agendaManager.getWorkoutsForDay(DateTime.now());
    final bool hasWorkoutToday = todayWorkouts.isNotEmpty;
    
    // Dynamic naming assignment fallback string if no data matches today's date
    final String nextWorkoutTitle = hasWorkoutToday ? todayWorkouts.first.name : "None scheduled";

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE), 
      body: Column(
        children: [
          const CustomHeader(title: "Home"), // Global full-width top navigation banner block

          Expanded(
            child: Center(
              child: Container(
                // RESPONSIVE LAYOUT CLAUSE: Clamps scrollable viewport strictly to 450px on desktop web systems
                constraints: const BoxConstraints(maxWidth: 450),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // --- TARGET ROUTINE FEEDBACK SECTION ---
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
                    
                    // --- ACTIONS HUB BOX CONTAINER ---
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
                            // Primary Action Button: Fires up tracking screens or shifts layout index pointers
                            ElevatedButton(
                              onPressed: () {
                                if (hasWorkoutToday) {
                                  // Pushes user into a dedicated screen running active session timers
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
                                  // Navigates user straight to Selection menus to allocate templates
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
                            
                            // Secondary Action Button: Navigates back up to calendar views
                            ElevatedButton(
                              onPressed: () => navManager.setIndex(1), // Index pointer targeting Agenda tabs
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
                    
                    // --- CENTRAL GRAPHIC DISPLAY ELEMENT ---
                    Center(
                      child: Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5), 
                          borderRadius: BorderRadius.circular(35), 
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.6), 
                            width: 5, // Thick stroke highlight outline styling
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