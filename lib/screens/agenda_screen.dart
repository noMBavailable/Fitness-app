import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../managers/agenda_manager.dart';
import '../managers/workout_manager.dart';
import '../managers/nav_manager.dart';
import '../widgets/custom_header.dart';
import '../widgets/swipe_nav_dock.dart';

class AgendaScreen extends StatefulWidget {
  final AgendaManager agendaManager;
  final WorkoutManager workoutManager;
  final NavManager navManager;

  const AgendaScreen({
    super.key, 
    required this.agendaManager, 
    required this.workoutManager,
    required this.navManager,
  });

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month; 
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Changed from 'late' to nullable to prevent initialization crashes
  AnimationController? _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize controller immediately
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

    // Trigger pulse after a short delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && _controller != null) {
        _controller!.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], 
      
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        // Safety check: Only build animation if controller is ready
        child: _controller == null 
          ? const SizedBox.shrink() 
          : ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B4DB).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: _showSchedulePicker,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  highlightElevation: 0,
                  child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 35),
                ),
              ),
            ),
      ),

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
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF00B4DB),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: _buildWorkoutList(),
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

  Widget _buildWorkoutList() {
    final workouts = widget.agendaManager.getWorkoutsForDay(_selectedDay ?? _focusedDay);
    if (workouts.isEmpty) {
      return const Center(child: Text("No workouts scheduled."));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160), 
      itemCount: workouts.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.fitness_center, color: Color(0xFF1A1A1A)),
        title: Text(workouts[index].name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Scheduled Workout"),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  void _showSchedulePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Schedule Workout",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: widget.workoutManager.workouts.length,
                itemBuilder: (context, index) {
                  final workout = widget.workoutManager.workouts[index];
                  return ListTile(
                    leading: const Icon(Icons.add_circle_outline, color: Color(0xFF00B4DB)),
                    title: Text(workout.name),
                    onTap: () {
                      widget.agendaManager.scheduleWorkout(_selectedDay ?? _focusedDay, workout);
                      Navigator.pop(context);
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}