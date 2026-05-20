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
  // --- STATE CONTROLLERS ---
  final _nameController = TextEditingController();
  List<Exercise> _tempSelected = []; // Temporarily holds checkboxes state choices in the sheet

  // --- ANIMATION PROPERTIES ---
  AnimationController? _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Instantiates a smooth loops animation track for the creation button shortcut
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

    _controller!.repeat(); // Continuously loops animation pulse scale states
  }

  @override
  void dispose() {
    _controller?.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // --- OVERLAY SHEET EDIT MANAGER ---
  
  // Displays an internal modal bottom sheet configured for creating or editing routines
  void _showWorkoutForm({Workout? workout}) {
    // If an object is passed, fill text fields with existing properties (Edit Mode)
    if (workout != null) {
      _nameController.text = workout.name;
      _tempSelected = List.from(workout.selectedExercises);
    } else {
      // Clear controllers to start fresh (Create Mode)
      _nameController.clear();
      _tempSelected = [];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to scale text fields above soft keyboards
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Center(
        child: Container(
          // Bounds the popup sheet inputs panel width cleanly on web displays
          constraints: BoxConstraints(maxWidth: kIsWeb ? 450 : double.infinity),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom, // Pushes elements above device keyboards
            left: 20, right: 20, top: 20,
          ),
          child: StatefulBuilder( // Enables internal state management updates inside the sheet loop
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
                
                // Scrollable Checkbox feed container
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
                          // Updates local state hooks specifically inside the bottom sheet view
                          setModalState(() {
                            if (val == true) {
                              _tempSelected.add(ex); // Append exercise instance reference
                            } else {
                              _tempSelected.removeWhere((e) => e.id == ex.id); // Strip index
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
                        // Route payload straight to database create collection path
                        await widget.workoutManager.addWorkout(_nameController.text, _tempSelected);
                      } else {
                        // Target existing document snapshot for update execution path
                        await widget.workoutManager.updateWorkout(
                          workout.id,
                          _nameController.text,
                          _tempSelected,
                        );
                      }
                      if (mounted) Navigator.pop(context); // Close editing template panel safely
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

  // --- CORE VIEW TREE BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      
      // Floating Addition Button shortcut container
      floatingActionButton: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450), // Keeps button aligned perfectly inside desktop viewport columns
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.only(bottom: 100, right: 16),
          child: _controller == null 
            ? const SizedBox.shrink() 
            : ScaleTransition(
                scale: _pulseAnimation, // Integrates looping pulse animation constraints
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
                    onPressed: () => _showWorkoutForm(), // Launches create routine bottom sheet
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
                    // Responsive width lock rule: Restricts content rows width to 450px on desktop web systems
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
                            
                            // Flag: Identifies if row index string keys match system premade template constants
                            final isPremade = workout.id.startsWith('w_pre_');

                            return ListTile(
                              leading: const Icon(Icons.fitness_center),
                              title: Text(workout.name),
                              subtitle: Text("${workout.selectedExercises.length} Exercises"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Edit Button: Always active and operational for all entries
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showWorkoutForm(workout: workout),
                                  ),
                                  // Delete Actions Handler: Custom items show red trash icons, premade items show locked indicators
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
          
          // Navigation Dock container alignment properties layout rules
          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: widget.navManager),
          ),
        ],
      ),
    );
  }
}