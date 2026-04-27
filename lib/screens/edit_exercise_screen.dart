import 'package:flutter/material.dart';

class EditExerciseScreen extends StatelessWidget {
  const EditExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Exercises")),
      body: const Center(child: Text("Exercise List Content Here")),
    );
  }
}