import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for responsive layout checks
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
    // 1. Calculate the peak weight entry in history to scale the graph heights dynamically
    double maxWeightInHistory = 0.0;
    for (var entry in manager.history) {
      if (entry.value > maxWeightInHistory) {
        maxWeightInHistory = entry.value;
      }
    }

    // 2. Determine variable height steps and ceilings to keep data axis ticks clean and uncrowded
    double dynamicMaxY = 100.0;  // Baseline graph ceiling height
    double labelInterval = 20.0; // Baseline numerical step (0, 20, 40...)

    if (maxWeightInHistory > 0) {
      if (maxWeightInHistory <= 100) {
        dynamicMaxY = 100;
        labelInterval = 20; // Max 5 labels
      } else if (maxWeightInHistory <= 200) {
        dynamicMaxY = 200;
        labelInterval = 40; // Max 5 labels
      } else if (maxWeightInHistory <= 400) {
        dynamicMaxY = 400;
        labelInterval = 100; // Max 4 labels
      } else {
        dynamicMaxY = 800; // Hard threshold safety barrier
        labelInterval = 200; // Max 4 labels
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE), // Global framework backdrop color
      body: Stack(
        children: [
          Column(
            children: [
              // Global tracking layout header block: showBackButton enables pop navigation paths
              const CustomHeader(
                title: "Weight History",
                showBackButton: true,
              ),
              
              Expanded(
                child: Center(
                  child: Container(
                    // RESPONSIVE CLAUSE: Clamps chart grid mesh and table sheets to 450px on desktop web systems
                    constraints: BoxConstraints(maxWidth: kIsWeb ? 450 : double.infinity),
                    child: Column(
                      children: [
                        // --- GRAPH DISPLAY SECTION ---
                        Container(
                          height: 320,
                          padding: const EdgeInsets.fromLTRB(15, 40, 25, 10),
                          child: manager.history.isEmpty
                              ? const Center(child: Text("No data to graph yet"))
                              : LineChart(
                                  LineChartData(
                                    minY: 0,
                                    maxY: dynamicMaxY, // Plugs in our dynamically calculated vertical scale range limit
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false, // Disables vertical bars to maximize layout clarity
                                      horizontalInterval: labelInterval, 
                                      getDrawingHorizontalLine: (value) => FlLine(
                                        color: Colors.black.withValues(alpha: 0.05), // Faint grid mesh background lines
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      
                                      // Y-AXIS MEASUREMENT CONFIGURATIONS
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: labelInterval, // Matches side numbering tags to background grid offsets
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
                                      
                                      // X-AXIS TIMELINE CONFIGURATIONS
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 1, // Steps incrementally across every entry snapshot in history 
                                          reservedSize: 30,
                                          getTitlesWidget: (value, meta) {
                                            int index = value.toInt();
                                            if (index >= 0 && index < manager.history.length) {
                                              DateTime date = manager.history[index].date;
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  DateFormat('dd/MM').format(date), // Formats date keys to standard shorthand day/month displays
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
                                      // Data Spline Vector Setup Layer
                                      LineChartBarData(
                                        spots: manager.history.asMap().entries.map((entry) {
                                          return FlSpot(
                                            entry.key.toDouble(), // Coordinates progress based on timeline index mappings
                                            entry.value.value.toDouble(), // Tracks numerical weight values
                                          );
                                        }).toList(),
                                        isCurved: true, // Smooths data point vector intersection junctions
                                        curveSmoothness: 0.35,
                                        color: Colors.blueAccent,
                                        barWidth: 4,
                                        dotData: const FlDotData(show: true), // Draws specific target circle markers onto indexes
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.blueAccent.withValues(alpha: 0.1), // Gentle gradient backdrop under the graph line
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const Divider(),
                        
                        // --- CHRONOLOGICAL DATA LIST VIEW SECTION ---
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 120), // Adds vertical padding buffer to float list above navigation docks
                            itemCount: manager.history.length,
                            itemBuilder: (context, index) {
                              // Reverses array loops mapping so newest metric entries render at top rows positions
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
                  ),
                ),
              ),
            ],
          ),
          
          // Primary Navigation Menu Dock Overlay module position alignment parameters
          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: navManager),
          ),
        ],
      ),
    );
  }
}