import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../managers/nav_manager.dart';
import '../managers/workout_manager.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;
  final NavManager navManager;
  final WorkoutManager workoutManager;

  const ActiveWorkoutScreen({
    super.key, 
    required this.workout, 
    required this.navManager,
    required this.workoutManager,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.workout.selectedExercises.isEmpty) {
      return const Scaffold(body: Center(child: Text("No exercises in this workout")));
    }

    final currentExercise = widget.workout.selectedExercises[_currentExerciseIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Soft light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.workout.name.toUpperCase(),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.black, size: 28),
            onPressed: () {
              // FIX: This now correctly closes the screen
              Navigator.pop(context); 
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Timer Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const Text("ELAPSED TIME", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(
                  _formatTime(_secondsElapsed),
                  style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildMainContent(currentExercise),
                  ),
                ),
              ],
            ),
          ),
          
          _buildControls(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMainContent(Exercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00B4DB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text("CURRENT EXERCISE", style: TextStyle(color: Color(0xFF00B4DB), fontWeight: FontWeight.bold, fontSize: 10)),
        ),
        const SizedBox(height: 8),
        Text(exercise.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1)),
        const SizedBox(height: 25),
        
        // Stats Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              _buildStatRow("SET", "$_currentSet / 4", Icons.repeat),
              const Divider(height: 30),
              _buildStatRow("TARGET", "${exercise.reps} Reps", Icons.track_changes),
              const Divider(height: 30),
              _buildStatRow("WEIGHT", "${exercise.weight} KG", Icons.fitness_center),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 90,
      color: Colors.transparent,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: widget.workout.selectedExercises.length,
        itemBuilder: (context, index) {
          bool isActive = _currentExerciseIndex == index;
          bool isCompleted = _currentExerciseIndex > index;
          
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 55, height: 55,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF1A1A1A) : (isCompleted ? Colors.green : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(color: isActive ? Colors.transparent : Colors.grey.withOpacity(0.3), width: 2),
                  boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                ),
                child: Center(
                  child: isCompleted 
                    ? const Icon(Icons.check, color: Colors.white)
                    : Text("${index + 1}", style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              if (index != widget.workout.selectedExercises.length - 1)
                Container(width: 2, height: 30, color: Colors.grey.withOpacity(0.2)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _controlButton(Icons.arrow_back_ios_new_rounded, () {
            setState(() {
              if (_currentSet > 1) { _currentSet--; }
              else if (_currentExerciseIndex > 0) {
                _currentExerciseIndex--;
                _currentSet = 4;
              }
            });
          }),
          
          // Complete Set / Next Button
          GestureDetector(
            onTap: () {
              setState(() {
                if (_currentSet < 4) { _currentSet++; }
                else if (_currentExerciseIndex < widget.workout.selectedExercises.length - 1) {
                  _currentExerciseIndex++;
                  _currentSet = 1;
                } else {
                  // Finish Workout
                  Navigator.pop(context);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00B4DB), Color(0xFF0083B0)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF00B4DB).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: const Text("NEXT SET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          _controlButton(Icons.arrow_forward_ios_rounded, () {
            setState(() {
              if (_currentSet < 4) { _currentSet++; }
              else if (_currentExerciseIndex < widget.workout.selectedExercises.length - 1) {
                _currentExerciseIndex++;
                _currentSet = 1;
              }
            });
          }),
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 28, color: Colors.black54),
      onPressed: onTap,
    );
  }
}