import 'package:flutter/material.dart';

class WeightEntry {
  final double value;
  final DateTime date;

  WeightEntry(this.value, this.date);
}

class WeightManager extends ChangeNotifier {
  // A list to store all our weight entries
  final List<WeightEntry> _history = [];

  List<WeightEntry> get history => _history;

  void addWeight(double weight) {
    _history.add(WeightEntry(weight, DateTime.now()));
    notifyListeners(); // This tells the UI to refresh
  }
}