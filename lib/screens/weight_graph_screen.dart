import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../managers/weight_manager.dart';
import '../managers/nav_manager.dart'; // Add this
import '../widgets/swipe_nav_dock.dart'; // Add this
import '../widgets/custom_header.dart';

class WeightGraphScreen extends StatelessWidget {
  final WeightManager manager;
  final NavManager navManager; // 1. Add NavManager

  const WeightGraphScreen({
    super.key, 
    required this.manager, 
    required this.navManager, // 2. Require it in constructor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // LAYER 1: THE CONTENT
          Column(
            children: [
              const CustomHeader(title: "Weight History"),
              
              // GRAPH SECTION
              Container(
                height: 300,
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
                child: manager.history.isEmpty
                    ? const Center(child: Text("No data to graph yet"))
                    : LineChart(
                        LineChartData(
                          // ... keep your existing LineChartData ...
                          
                        ),
                      ),
              ),
              const Divider(),
              // LIST SECTION
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120), // Leave room for dock
                  itemCount: manager.history.length,
                  itemBuilder: (context, index) {
                    final entry = manager.history.reversed.toList()[index];
                    return ListTile(
                      leading: const Icon(Icons.monitor_weight),
                      title: Text("${entry.value} kg"),
                      subtitle: Text("${entry.date.day}/${entry.date.month}/${entry.date.year}"),
                    );
                  },
                ),
              ),
            ],
          ),

          // LAYER 2: THE FLOATING NAVBAR
          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: navManager),
          ),
        ],
      ),
    );
  }
}