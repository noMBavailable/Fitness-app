import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../managers/nav_manager.dart'; // Add this to handle the X button

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;
  final NavManager navManager; // Added to control navigation

  const ActiveWorkoutScreen({
    super.key, 
    required this.workout, 
    required this.navManager
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
    _startTimer(); // Starts automatically as you requested
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
    // Safety check for empty workouts
    if (widget.workout.selectedExercises.isEmpty) {
      return const Center(child: Text("No exercises in this workout"));
    }

    final currentExercise = widget.workout.selectedExercises[_currentExerciseIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        leading: const Icon(Icons.settings, color: Colors.black),
        title: Text(widget.workout.name.toUpperCase(), 
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 30),
            onPressed: () {
              // FIX: Instead of pop, we switch the nav index back to Home
              widget.navManager.setIndex(0); // might be Navigator.pop(context) if you want to just pop the screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            _formatTime(_secondsElapsed),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSidebar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${currentExercise.name}:", 
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("Set $_currentSet:", 
                          style: const TextStyle(fontSize: 26)),
                        Text("${currentExercise.reps} reps ${currentExercise.weight}kg", 
                          style: const TextStyle(fontSize: 26)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildArrows(),
          const SizedBox(height: 100), // Room for the SwipeNavDock
        ],
      ),
    );
  }

  Widget _buildSidebar() {
  return Container(
    // Option 1: Increase this width to 120 or 130 to fit the 65px box + 40px icon
    width: 120, 
    padding: const EdgeInsets.only(left: 10),
    child: SingleChildScrollView(
      child: Column(
        children: [
          _sidebarBox("Start"),
          const Icon(Icons.arrow_downward, size: 16),
          ...List.generate(widget.workout.selectedExercises.length, (index) {
            bool isActive = _currentExerciseIndex == index;
            return Column(
              children: [
                // Use a Stack or wrap in a Row with no constraints to prevent overflow
                Row(
                  mainAxisSize: MainAxisSize.min, // Keep the row as small as possible
                  children: [
                    _sidebarBox(
                      widget.workout.selectedExercises[index].name,
                      isActive: isActive,
                    ),
                    // Use a smaller icon or a sized box to prevent the 10px overflow
                    if (isActive) 
                      const Icon(Icons.arrow_left, size: 30), // Reduced from 40 to 30
                  ],
                ),
                const Icon(Icons.arrow_downward, size: 16),
              ],
            );
          }),
          _sidebarBox("Finish", color: Colors.greenAccent),
        ],
      ),
    ),
  );
}

  Widget _sidebarBox(String label, {bool isActive = false, Color? color}) {
    return Container(
      width: 65, height: 65,
      decoration: BoxDecoration(
        color: color ?? (isActive ? Colors.white : Colors.grey[300]),
        border: Border.all(color: Colors.black, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildArrows() {
    return Padding(
      padding: const EdgeInsets.only(right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_circle_left, size: 70, color: Colors.blueAccent),
            onPressed: () {
              setState(() {
                if (_currentSet > 1) { _currentSet--; }
                else if (_currentExerciseIndex > 0) {
                  _currentExerciseIndex--;
                  _currentSet = 4;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_circle_right, size: 70, color: Colors.blueAccent),
            onPressed: () {
              setState(() {
                if (_currentSet < 4) { _currentSet++; }
                else if (_currentExerciseIndex < widget.workout.selectedExercises.length - 1) {
                  _currentExerciseIndex++;
                  _currentSet = 1;
                }
              });
            },
          ),
        ],
      ),
    );
  }
}