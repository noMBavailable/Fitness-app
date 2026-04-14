import 'package:flutter/material.dart';

class NavItem {
  final String title;
  final IconData icon; // this is for built in icons. use final String imagepath for custom pngs

  NavItem({required this.title, required this.icon});
}

class NavManager extends ChangeNotifier {
  int _currentIndex = 0;
  
  final List<NavItem> items = [
    NavItem(title: 'Workout', icon: Icons.fitness_center),
    NavItem(title: 'Weight', icon: Icons.scale_outlined),
    NavItem(title: 'Notes', icon: Icons.note_add_outlined),
    NavItem(title: 'Agenda', icon: Icons.calendar_month),
    NavItem(title: 'Run', icon: Icons.run_circle_outlined),
  ];

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners(); // This tells the UI to rebuild
  }
}