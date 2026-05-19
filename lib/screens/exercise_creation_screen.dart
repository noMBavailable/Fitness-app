import 'package:flutter/material.dart';
import '../managers/exercise_manager.dart';
import '../models/exercise_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/swipe_nav_dock.dart';
import '../managers/nav_manager.dart';

class ExerciseCreationScreen extends StatefulWidget {
  final ExerciseManager manager;
  final NavManager navManager;

  const ExerciseCreationScreen({super.key, required this.manager, required this.navManager});

  @override
  State<ExerciseCreationScreen> createState() => _ExerciseCreationScreenState();
}

class _ExerciseCreationScreenState extends State<ExerciseCreationScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  // Animation setup
  AnimationController? _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize pulsing animation to match Agenda Screen
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

    // Start the pulsing loop
    _controller!.repeat();
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _controller?.dispose();
    _nameController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _showForm({Exercise? exercise}) {
    if (exercise != null) {
      _nameController.text = exercise.name;
      _repsController.text = exercise.reps.toString();
      _weightController.text = exercise.weight.toString();
    } else {
      _nameController.clear();
      _repsController.clear();
      _weightController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Exercise Name')),
            TextField(
                controller: _repsController,
                decoration: const InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number),
            TextField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                final reps = int.tryParse(_repsController.text) ?? 0;
                final weight = double.tryParse(_weightController.text) ?? 0.0;

                if (exercise == null) {
                  widget.manager.addExercise(name, reps, weight);
                } else {
                  widget.manager.updateExercise(exercise.id, name, reps, weight);
                }
                Navigator.pop(context);
              },
              child: Text(exercise == null ? 'Add' : 'Update'),
            ),
            const SizedBox(height: 20),
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
                        color: const Color(0xFF00B4DB).withValues(alpha:0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () => _showForm(),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    highlightElevation: 0,
                    child: const Icon(Icons.add, color: Colors.white, size: 35),
                  ),
                ),
              ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const CustomHeader(title: "My Exercises", showBackButton: true),
              Expanded(
                child: ListenableBuilder(
                    listenable: widget.manager,
                    builder: (context, _) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 160),
                        itemCount: widget.manager.exercises.length,
                        itemBuilder: (ctx, i) {
                          final ex = widget.manager.exercises[i];
                          return ListTile(
                            title: Text(ex.name),
                            subtitle: Text("${ex.reps} reps @ ${ex.weight} kg"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showForm(exercise: ex)),
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        widget.manager.deleteExercise(ex.id)),
                              ],
                            ),
                          );
                        },
                      );
                    }),
              )
            ],
          ),
          Align(
              alignment: const Alignment(0, 0.92),
              child: SwipeNavDock(manager: widget.navManager)),
        ],
      ),
    );
  }
}