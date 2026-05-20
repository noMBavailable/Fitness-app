import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Added for web environment checking
import '../managers/exercise_manager.dart';
import '../managers/workout_manager.dart';
import '../managers/nav_manager.dart'; 
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../widgets/swipe_nav_dock.dart';
import '../widgets/custom_header.dart';

class EditWorkoutScreen extends StatefulWidget {
  final ExerciseManager exerciseManager;
  final WorkoutManager workoutManager;
  final NavManager navManager;

  const EditWorkoutScreen({
    super.key,
    required this.exerciseManager,
    required this.workoutManager,
    required this.navManager,
  });

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  List<Exercise> _tempSelected = [];

  // Animation setup
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

    _controller!.repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showWorkoutForm({Workout? workout}) {
    if (workout != null) {
      _nameController.text = workout.name;
      _tempSelected = List.from(workout.selectedExercises);
    } else {
      _nameController.clear();
      _tempSelected = [];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Center(
        child: Container(
          // Bounds the popup workout editor sheet inputs cleanly on web screens
          constraints: BoxConstraints(maxWidth: kIsWeb ? 450 : double.infinity),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(workout == null ? "New Workout" : "Edit Workout", 
                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Workout Name"),
                ),
                const SizedBox(height: 10),
                const Text("Select Exercises:"),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: widget.exerciseManager.exercises.length,
                    itemBuilder: (context, index) {
                      final ex = widget.exerciseManager.exercises[index];
                      final isSelected = _tempSelected.any((e) => e.id == ex.id);
                      
                      return CheckboxListTile(
                        title: Text(ex.name),
                        value: isSelected,
                        onChanged: (val) {
                          setModalState(() {
                            if (val == true) {
                              _tempSelected.add(ex);
                            } else {
                              _tempSelected.removeWhere((e) => e.id == ex.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isNotEmpty) {
                      if (workout == null) {
                        await widget.workoutManager.addWorkout(_nameController.text, _tempSelected);
                      } else {
                        await widget.workoutManager.updateWorkout(
                          workout.id,
                          _nameController.text,
                          _tempSelected,
                        );
                      }
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text("Save Workout"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      // Keeps the pulsed workout-addition button inside the 450px content column layout zone on desktop screens
      floatingActionButton: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.only(bottom: 100, right: 16),
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
                    onPressed: () => _showWorkoutForm(),
                    backgroundColor: Colors.transparent,
                    elevation: 0, highlightElevation: 0,
                    child: const Icon(Icons.add, color: Colors.white, size: 35),
                  ),
                ),
              ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const CustomHeader(title: "Edit Workouts", showBackButton: true),
              Expanded(
                child: Center(
                  child: Container(
                    // Restricts the core list item configurations to 450px wide layout boundaries on web targets
                    constraints: BoxConstraints(maxWidth: kIsWeb ? 450 : double.infinity),
                    child: ListenableBuilder(
                      listenable: widget.workoutManager,
                      builder: (context, _) {
                        final workouts = widget.workoutManager.workouts;
                        
                        if (workouts.isEmpty) {
                          return const Center(child: Text("No workouts created yet."));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 160), 
                          itemCount: workouts.length,
                          itemBuilder: (context, index) {
                            final workout = workouts[index];
                            
                            // Identify if this workout item row is a system-wide premade template asset
                            final isPremade = workout.id.startsWith('w_pre_');

                            return ListTile(
                              leading: const Icon(Icons.fitness_center),
                              title: Text(workout.name),
                              subtitle: Text("${workout.selectedExercises.length} Exercises"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Edit Button: Always available for both premade and custom workouts
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showWorkoutForm(workout: workout),
                                  ),
                                  // Delete Action Container: Show red trash button for custom, lock icon for premade templates
                                  isPremade
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                                          child: Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 22),
                                        )
                                      : IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            widget.workoutManager.deleteWorkout(workout.id);
                                          },
                                        ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
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
}