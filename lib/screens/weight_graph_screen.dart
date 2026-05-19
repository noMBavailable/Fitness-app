import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../managers/weight_manager.dart';
import '../managers/nav_manager.dart'; 
import '../widgets/swipe_nav_dock.dart'; 
import '../widgets/custom_header.dart';

class WeightGraphScreen extends StatelessWidget {
  final WeightManager manager;
  final NavManager navManager; 

  const WeightGraphScreen({
    super.key, 
    required this.manager, 
    required this.navManager, 
  });

  @override
  Widget build(BuildContext context) {
    // 1. Find the maximum weight entry in history to scale dynamically
    double maxWeightInHistory = 0.0;
    for (var entry in manager.history) {
      if (entry.value > maxWeightInHistory) {
        maxWeightInHistory = entry.value;
      }
    }

    // 2. Set a dynamic ceiling and interval so the labels stay perfectly clean
    double dynamicMaxY = 100.0; // Starting baseline ceiling
    double labelInterval = 20.0; // Starting baseline step (0, 20, 40, 60, 80...)

    if (maxWeightInHistory > 0) {
      if (maxWeightInHistory <= 100) {
        dynamicMaxY = 100;
        labelInterval = 20; // Max 5 labels (Clean!)
      } else if (maxWeightInHistory <= 200) {
        dynamicMaxY = 200;
        labelInterval = 40; // Max 5 labels
      } else if (maxWeightInHistory <= 400) {
        dynamicMaxY = 400;
        labelInterval = 100; // Max 4 labels
      } else {
        dynamicMaxY = 800; // Hard limit fallback
        labelInterval = 200; // Max 4 labels
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Column(
            children: [
              const CustomHeader(
                title: "Weight History",
                showBackButton: true,
              ),
              
              // GRAPH SECTION
              Container(
                height: 320,
                padding: const EdgeInsets.fromLTRB(15, 40, 25, 10),
                child: manager.history.isEmpty
                    ? const Center(child: Text("No data to graph yet"))
                    : LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: dynamicMaxY, // Adapts seamlessly based on current data
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: labelInterval, 
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.black.withValues(alpha: 0.05),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            // --- ADAPTIVE Y-AXIS CONFIGURATION ---
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: labelInterval, // Adjusts dynamically to prevent crowding
                                reservedSize: 45,
                                getTitlesWidget: (value, meta) {
                                  if (value < 0 || value > dynamicMaxY) return const SizedBox.shrink();
                                  return Text(
                                    "${value.toInt()}",
                                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.right,
                                  );
                                },
                              ),
                            ),
                            // --- X-AXIS CONFIGURATION ---
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1, 
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < manager.history.length) {
                                    DateTime date = manager.history[index].date;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        DateFormat('dd/MM').format(date),
                                        style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                              left: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: manager.history.asMap().entries.map((entry) {
                                return FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.value.toDouble(),
                                );
                              }).toList(),
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: Colors.blueAccent,
                              barWidth: 4,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blueAccent.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const Divider(),
              // LIST SECTION
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120), 
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
          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: navManager),
          ),
        ],
      ),
    );
  }
}