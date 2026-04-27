import 'package:flutter/material.dart';

class EditWorkoutScreen extends StatelessWidget {
  const EditWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Workout")),
      body: const Center(child: Text("Workout Editor Content Here")),
    );
  }
}