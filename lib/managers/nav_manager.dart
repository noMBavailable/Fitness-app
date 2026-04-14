import 'package:flutter/material.dart';

class NavManager extends ChangeNotifier {
  int _currentIndex = 0;
  
  final List<String> items = ['Workout', 'Progress', 'Nutrition', 'Social', 'Settings', 'Profile'];

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners(); // This tells the UI to rebuild
  }
}