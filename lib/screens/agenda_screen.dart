import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../managers/agenda_manager.dart';
import '../managers/workout_manager.dart';
import '../models/workout_model.dart';
import '../widgets/custom_header.dart';

class AgendaScreen extends StatefulWidget {
  final AgendaManager agendaManager;
  final WorkoutManager workoutManager;

  const AgendaScreen({super.key, required this.agendaManager, required this.workoutManager});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month; // This is where you'd change to .week
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
            // This displays dots under days that have workouts
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showSchedulePicker,
        child: const Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildWorkoutList() {
    final workouts = widget.agendaManager.getWorkoutsForDay(_selectedDay ?? _focusedDay);
    if (workouts.isEmpty) return const Center(child: Text("No workouts scheduled."));

    return ListView.builder(
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