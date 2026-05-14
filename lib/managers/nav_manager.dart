import 'package:flutter/material.dart';

class NavItem {
  final String title;
  final IconData icon;

  NavItem({required this.title, required this.icon});
}

class NavManager extends ChangeNotifier {
  int _currentIndex = 0;
  
  final List<NavItem> items = [
    NavItem(title: 'Home', icon: Icons.home_outlined),
    NavItem(title: 'Agenda', icon: Icons.calendar_month),
    NavItem(title: 'Weight', icon: Icons.scale_outlined),
    NavItem(title: 'Exercises', icon: Icons.fitness_center),
    NavItem(title: 'Active', icon: Icons.play_circle_outline),
    NavItem(title: 'Notes', icon: Icons.notes_outlined),
  ];

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex == index) return; // Optimization
    _currentIndex = index;
    notifyListeners();
  }
}