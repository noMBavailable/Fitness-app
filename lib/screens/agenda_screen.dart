import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../managers/agenda_manager.dart';
import '../managers/workout_manager.dart';
import '../managers/nav_manager.dart'; // 1. Added
import '../widgets/custom_header.dart';
import '../widgets/swipe_nav_dock.dart'; // 2. Added

class AgendaScreen extends StatefulWidget {
  final AgendaManager agendaManager;
  final WorkoutManager workoutManager;
  final NavManager navManager; // 3. Added

  const AgendaScreen({
    super.key, 
    required this.agendaManager, 
    required this.workoutManager,
    required this.navManager, // 4. Added
  });

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month; 
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Match your app theme
      
      // 5. PUSH FAB NORTH
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90), // Pushes it above the Navbar
        child: FloatingActionButton(
          backgroundColor: Color.fromARGB(255, 75, 75, 75), // Match your dock color
          onPressed: _showSchedulePicker,
          child: const Icon(Icons.calendar_today, color: Colors.white),
        ),
      ),

      // 6. WRAP IN STACK
      body: Stack(
        children: [
          Column(
            children: [
              const CustomHeader(title: "Agenda"),
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) {
                  return widget.agendaManager.getWorkoutsForDay(day);
                },
              ),
              const Divider(),
              Expanded(
                child: _buildWorkoutList(),
              ),
            ],
          ),

          // 7. THE NAVBAR LAYER
          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: widget.navManager),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutList() {
    final workouts = widget.agendaManager.getWorkoutsForDay(_selectedDay ?? _focusedDay);
    if (workouts.isEmpty) {
      return const Center(child: Text("No workouts scheduled."));
    }

    return ListView.builder(
      // 8. ADD BOTTOM PADDING TO LIST
      // This ensures you can scroll the last workout above the Navbar/FAB
      padding: const EdgeInsets.only(bottom: 160), 
      itemCount: workouts.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.fitness_center),
        title: Text(workouts[index].name),
      ),
    );
  }

  void _showSchedulePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: widget.workoutManager.workouts.length,
        itemBuilder: (context, index) {
          final workout = widget.workoutManager.workouts[index];
          return ListTile(
            title: Text(workout.name),
            onTap: () {
              widget.agendaManager.scheduleWorkout(_selectedDay ?? _focusedDay, workout);
              Navigator.pop(context);
              setState(() {});
            },
          );
        },
      ),
    );
  }
}