import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../managers/agenda_manager.dart';
import '../managers/workout_manager.dart';
import '../managers/nav_manager.dart';
import '../widgets/custom_header.dart';
import '../widgets/swipe_nav_dock.dart';
import '../models/workout_model.dart'; 

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

  AnimationController? _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

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

  void _showWorkoutPicker({Workout? workoutToReplace}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      workoutToReplace == null ? "Choose Workout" : "Change Workout",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 48), 
              ],
            ),
            const Divider(height: 25),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.workoutManager,
                builder: (context, _) {
                  if (widget.workoutManager.workouts.isEmpty) {
                    return const Center(child: Text("No workouts available."));
                  }
                  return ListView.builder(
                    itemCount: widget.workoutManager.workouts.length,
                    itemBuilder: (context, index) {
                      final workout = widget.workoutManager.workouts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: ListTile(
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          leading: const Icon(Icons.fitness_center, color: Color(0xFF00B4DB)),
                          title: Text(workout.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${workout.selectedExercises.length} exercises"),
                          trailing: Icon(
                            workoutToReplace == null ? Icons.add_circle_outline : Icons.swap_horiz_rounded, 
                            color: workoutToReplace == null ? Colors.green : Colors.orange
                          ),
                          onTap: () async {
                            final date = _selectedDay ?? _focusedDay;
                            
                            if (workoutToReplace != null) {
                              await widget.agendaManager.removeWorkoutFromDay(date, workoutToReplace);
                            }
                            
                            await widget.agendaManager.scheduleWorkout(date, workout);
                            if (mounted) Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], 
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: _controller == null 
          ? const SizedBox.shrink() 
          : ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                height: 75, width: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B4DB).withValues(alpha:0.4),
                      blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () => _showWorkoutPicker(),
                  backgroundColor: Colors.transparent,
                  elevation: 0, highlightElevation: 0,
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
              // 1. LISTENING CALENDAR: Forces blue dots to appear instantly
              ListenableBuilder(
                listenable: widget.agendaManager,
                builder: (context, _) {
                  return TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) => widget.agendaManager.getWorkoutsForDay(day),
                    calendarStyle: const CalendarStyle(
                      markerDecoration: BoxDecoration(color: Color.fromARGB(255, 0, 0, 0), shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(color: Color(0xFF00B4DB), shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(color: Color(0xFF1A1A1A), shape: BoxShape.circle),
                    ),
                  );
                }
              ),
              const Divider(),
              // 2. LISTENING WORKOUT LIST: Updates the list below the calendar
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.agendaManager,
                  builder: (context, _) => _buildWorkoutList(),
                ),
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
    final selectedDate = _selectedDay ?? _focusedDay;
    final workouts = widget.agendaManager.getWorkoutsForDay(selectedDate);
    
    if (workouts.isEmpty) {
      return const Center(child: Text("No workouts scheduled."));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];

        return Dismissible(
          key: Key('${workout.id}_${selectedDate.millisecondsSinceEpoch}'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            widget.agendaManager.removeWorkoutFromDay(selectedDate, workout);
          },
          child: ListTile(
            onTap: () => _showWorkoutPicker(workoutToReplace: workout), 
            leading: const Icon(Icons.fitness_center, color: Color(0xFF1A1A1A)),
            title: Text(workout.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${workout.selectedExercises.length} exercises - Tap to change"),
            trailing: const Icon(Icons.chevron_left, color: Color.fromARGB(255, 126, 126, 126), size: 32),
          ),
        );
      },
    );
  }
}