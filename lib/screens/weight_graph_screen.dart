import 'package:flutter/material.dart';
import '../managers/weight_manager.dart';

class WeightGraphScreen extends StatelessWidget {
  final WeightManager manager;

  const WeightGraphScreen({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weight History")),
      body: ListView.builder(
        itemCount: manager.history.length,
        itemBuilder: (context, index) {
          final entry = manager.history[index];
          return ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: Text("${entry.value} kg"),
            subtitle: Text("${entry.date.day}/${entry.date.month}"),
          );
        },
      ),
    );
  }
}