import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Added for web environment checking
import 'package:flutter/services.dart'; 
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
      builder: (ctx) => Center(
        child: Container(
          // FIX: Keeps the bottom sheet form input width compact on desktop web views
          constraints: BoxConstraints(maxWidth: kIsWeb ? 450 : double.infinity),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      // FIX: Bounds the floating creation button inside the 450px column limit on browser screens
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
                      onPressed: () => _showForm(),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      highlightElevation: 0,
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
              const CustomHeader(title: "My Exercises", showBackButton: true),
              Expanded(
                child: Center(
                  child: Container(
                    // FIX: Clamps the list view rows to a clean width on Web viewports
                    constraints: BoxConstraints(maxWidth: kIsWeb ? 450 : double.infinity),
                    child: ListenableBuilder(
                        listenable: widget.manager,
                        builder: (context, _) {
                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 160),
                            itemCount: widget.manager.exercises.length,
                            itemBuilder: (ctx, i) {
                              final ex = widget.manager.exercises[i];
                              
                              // Identify if this row is a core system premade template asset
                              final isPremade = ex.id.startsWith('pre_');

                              return ListTile(
                                title: Text(ex.name),
                                subtitle: Text("${ex.reps} reps @ ${ex.weight} kg"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Edit button remains fully operational for all items
                                    IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _showForm(exercise: ex)),
                                    // Delete action transforms into a locked lock icon for premade assets
                                    isPremade
                                        ? const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                                            child: Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 22),
                                          )
                                        : IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => widget.manager.deleteExercise(ex.id),
                                          ),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                  ),
                ),
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