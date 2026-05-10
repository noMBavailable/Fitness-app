// This would be a new widget file: lib/widgets/weight_modal.dart
import 'package:flutter/material.dart';
import '../screens/weight_graph_screen.dart'; // Add this import
import '../managers/weight_manager.dart';
import '../managers/nav_manager.dart';

class WeightModal extends StatelessWidget {
  final WeightManager manager;
  final TextEditingController _controller = TextEditingController();
  final NavManager navManager;

  WeightModal({super.key, required this.manager, required this.navManager});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Column(
            children: [
              const Text(
                "Current Weight",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controller, // Link the controller
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "kg",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Save the weight when pressed
                  double? value = double.tryParse(_controller.text);
                  if (value != null) {
                    manager.addWeight(value);
                    _controller.clear();
                    FocusScope.of(context).unfocus(); // Close keyboard
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text(
                  "Confirm",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const Divider(),
              const Text(
                "Weight History",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              // inside lib/widgets/weight_modal.dart
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeightGraphScreen(
                        manager: manager,
                        navManager: navManager, // Pass it here!
                      ),
                    ),
                  );
                },
                child: const Text("View Graph →"),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 30),
      ],
    );
  }
}
