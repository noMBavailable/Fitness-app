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
  // --- STATE VARIABLES ---
  Timer? _timer;               // Handles the ticking second increment background thread
  int _secondsElapsed = 0;     // Keeps track of cumulative active workout time
  int _currentExerciseIndex = 0; // Pointer index for active workout track lists
  int _currentSet = 1;         // Standard local tracking index bounded up to 4
  bool _isPaused = true;       // Safeguard status to start sessions on explicit user command

  @override
  void initState() {
    super.initState();
    _startTimer(); // Boot up timer system sequence on page initialization
  }

  // --- BUSINESS LOGIC FUNCTIONS ---

  // Instantiates a periodic 1-second checker to increment session timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Only process state modification if screen is currently active and not paused
      if (mounted && !_isPaused) { 
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  // Switches between ticking active timeline states
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  // Converts total raw integers into a standard MM:SS display format
  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  // Handles total system cleanup and success routing upon routine completion
  void _finishWorkout() {
    // 1. Kill the background timer loop execution context
    _timer?.cancel();
    
    // 2. Synchronize completion timestamp log properties to Firebase
    widget.workoutManager.markWorkoutAsCompleted();

    // 3. Show un-dismissible completion success feedback card
    showDialog(
      context: context,
      barrierDismissible: false, // Forces intentional action on the exit button
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            // Decorative container rendering a success trophy
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_rounded, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              "Workout Complete!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Awesome job crushing ${widget.workout.name}!",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 30),
            // Duration metrics feedback display container
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "Total Time: ${_formatTime(_secondsElapsed)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 25),
            // Navigation dismiss action button redirecting out of the sub-stack layout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);     // Dissolves the active popup container dialog
                  Navigator.pop(context); // Pops active screen view track back to root
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Back to Home", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Kill any remaining loops when layout leaves tracking loop contexts
    super.dispose();
  }

  // --- UI TREE LAYOUT RENDERING ---
  @override
  Widget build(BuildContext context) {
    // Return empty fallback scaffold if an asset layout contains empty collections
    if (widget.workout.selectedExercises.isEmpty) {
      return const Scaffold(body: Center(child: Text("No exercises in this workout")));
    }

    // Reference context to compile matching indices configurations
    final currentExercise = widget.workout.selectedExercises[_currentExerciseIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
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
              Navigator.pop(context); // Quick close button out of workout routine
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Timer Block: Displays elapsed metrics at layout columns head sections
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Text(
                  _isPaused ? "PAUSED" : "ELAPSED TIME", 
                  style: TextStyle(color: _isPaused ? Colors.orange : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  _formatTime(_secondsElapsed),
                  style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                ),
              ],
            ),
          ),
          
          // Primary View Layout Core: Left hand sidebar node array alongside central panels
          Expanded(
            child: Row(
              children: [
                _buildSidebar(), // Keeps tracking index positions visual elements on layout bounds
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildMainContent(currentExercise),
                  ),
                ),
              ],
            ),
          ),
          
          _buildControls(), // Active session interaction control modules
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Renders descriptions and workout specifics targeting current exercise configurations
  Widget _buildMainContent(Exercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00B4DB).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text("CURRENT EXERCISE", style: TextStyle(color: Color(0xFF00B4DB), fontWeight: FontWeight.bold, fontSize: 10)),
        ),
        const SizedBox(height: 8),
        Text(exercise.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1)),
        const SizedBox(height: 25),
        
        // Exercise Specifications Metadata display column sheet block
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
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

  // Flex alignment structural component wrapper inside individual rows mappings
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

  // Left vertical navigation strip tracking list array progress metrics states
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
                  border: Border.all(color: isActive ? Colors.transparent : Colors.grey.withValues(alpha: 0.3), width: 2),
                  boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                ),
                child: Center(
                  child: isCompleted 
                    ? const Icon(Icons.check, color: Colors.white)
                    : Text("${index + 1}", style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              // Render line connector paths unless dealing with tail elements mappings
              if (index != widget.workout.selectedExercises.length - 1)
                Container(width: 2, height: 30, color: Colors.grey.withValues(alpha: 0.2)),
            ],
          );
        },
      ),
    );
  }

  // Footer navigation actions handling state transitions
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Arrow: Reverts current set counts or downshifts indexes backwards
          _controlButton(Icons.arrow_back_ios_new_rounded, () {
            setState(() {
              if (_currentSet > 1) { _currentSet--; }
              else if (_currentExerciseIndex > 0) {
                _currentExerciseIndex--;
                _currentSet = 4; // Safely default back up to tail bounds
              }
            });
          }),
          
          // Central interaction button toggling session timer increments
          GestureDetector(
            onTap: _togglePause,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isPaused 
                    ? [const Color(0xFF11998e), const Color(0xFF38ef7d)]  // Green system theme
                    : [const Color(0xFF00B4DB), const Color(0xFF0083B0)]  // Blue running theme
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_isPaused ? const Color(0xFF11998e) : const Color(0xFF00B4DB)).withValues(alpha: 0.3), 
                    blurRadius: 15, 
                    offset: const Offset(0, 8)
                  )
                ],
              ),
              child: Icon(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // Right Arrow: Increments track pointers forward or routes closure routines
          _controlButton(Icons.arrow_forward_ios_rounded, () {
            setState(() {
              if (_currentSet < 4) { _currentSet++; }
              else if (_currentExerciseIndex < widget.workout.selectedExercises.length - 1) {
                _currentExerciseIndex++;
                _currentSet = 1; // Safely reset tracking index numbers values back down
              } else {
                // If every set and index has been exhausted, run completion logic loop 
                _finishWorkout();
              }
            });
          }),
        ],
      ),
    );
  }

  // Base layout abstract icon action button wrapper
  Widget _controlButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 28, color: Colors.black54),
      onPressed: onTap,
    );
  }
}