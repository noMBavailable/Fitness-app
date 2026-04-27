// This would be a new widget file: lib/widgets/weight_modal.dart
import 'package:flutter/material.dart';

class WeightModal extends StatelessWidget {
  const WeightModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. THE BUBBLE
        Container(
          width: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Column(
            children: [
              const Text("Current Weight", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Input Field
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "kg",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              const SizedBox(height: 10),
              // Confirm Button
              ElevatedButton(
                onPressed: () {}, 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text("Confirm"),
              ),
              const Divider(),
              // History Section
              const Text("Weight History", style: TextStyle(fontSize: 12, color: Colors.grey)),
              TextButton(
                onPressed: () => print("Go to Graph"),
                child: const Text("View Graph →"),
              ),
            ],
          ),
        ),
        // 2. THE ARROW (A small triangle)
        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 30),
      ],
    );
  }
}