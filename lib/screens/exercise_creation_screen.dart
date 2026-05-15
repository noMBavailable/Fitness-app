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

class _ExerciseCreationScreenState extends State<ExerciseCreationScreen> {
  final _nameController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

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
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Exercise Name')),
            TextField(controller: _repsController, decoration: const InputDecoration(labelText: 'Reps'), keyboardType: TextInputType.number),
            TextField(controller: _weightController, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(onPressed: () => _showForm(), child: const Icon(Icons.add)),
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
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: widget.manager.exercises.length,
                      itemBuilder: (ctx, i) {
                        final ex = widget.manager.exercises[i];
                        return ListTile(
                          title: Text(ex.name),
                          subtitle: Text("${ex.reps} reps @ ${ex.weight} kg"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(exercise: ex)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => widget.manager.deleteExercise(ex.id)),
                            ],
                          ),
                        );
                      },
                    );
                  }
                ),
              )
            ],
          ),
          Align(alignment: const Alignment(0, 0.92), child: SwipeNavDock(manager: widget.navManager)),
        ],
      ),
    );
  }
}