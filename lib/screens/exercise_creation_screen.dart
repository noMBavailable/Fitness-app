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

  void _showExerciseForm({Exercise? exercise}) {
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom, 
          left: 20, right: 20, top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Exercise Name')),
            TextField(controller: _repsController, decoration: const InputDecoration(labelText: 'Reps'), keyboardType: TextInputType.number),
            TextField(controller: _weightController, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (exercise == null) {
                  widget.manager.addExercise(_nameController.text, int.parse(_repsController.text), double.parse(_weightController.text));
                } else {
                  widget.manager.updateExercise(exercise.id, _nameController.text, int.parse(_repsController.text), double.parse(_weightController.text));
                }
                Navigator.pop(context);
                setState(() {}); 
              },
              child: Text(exercise == null ? 'Add Exercise' : 'Save Changes'),
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
      // Push the FAB up so it doesn't collide with the SwipeNavDock
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          onPressed: () => _showExerciseForm(),
          child: const Icon(Icons.add),
        ),
      ),
      // Using a Stack to layer the Navbar on top of the list
      body: Stack(
        children: [
          Column(
            children: [
              const CustomHeader(title: "My Exercises",
              showBackButton: true,),
              Expanded(
                child: ListView.builder(
                  // 120px padding at the bottom ensures the last exercise 
                  // is scrollable above the floating navbar
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
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _showExerciseForm(exercise: ex)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red), 
                            onPressed: () {
                              widget.manager.deleteExercise(ex.id);
                              setState(() {});
                            }
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),

          // THE FLOATING NAVBAR
          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: widget.navManager),
          ),
        ],
      ),
    );
  }
}