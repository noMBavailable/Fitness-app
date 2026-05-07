import 'package:flutter/material.dart';
import '../managers/weight_manager.dart';
import 'package:fl_chart/fl_chart.dart';

class WeightGraphScreen extends StatelessWidget {
  final WeightManager manager;

  const WeightGraphScreen({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weight History")),
      body: Column(
        children: [
          // THE GRAPH SECTION
          Container(
            height: 300,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
            child: manager.history.isEmpty
                ? const Center(child: Text("No data to graph yet"))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        // Bottom titles can be added later to show dates
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.black12),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          // Mapping history entries to graph spots
                          spots: manager.history.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(), // X = Index in list
                              entry.value.value.toDouble(), // Y = Weight value
                            );
                          }).toList(),
                          isCurved: true,
                          color: Colors.blueAccent,
                          barWidth: 4,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const Divider(),
          // THE LIST SECTION
          Expanded(
            child: ListView.builder(
              itemCount: manager.history.length,
              itemBuilder: (context, index) {
                // Display newest entries at the bottom or top depending on your list order
                final entry = manager.history[index];
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
    );
  }
}