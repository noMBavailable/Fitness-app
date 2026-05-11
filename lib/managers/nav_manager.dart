import 'package:flutter/material.dart';

class NavItem {
  final String title;
  final IconData icon; // this is for built in icons. use final String imagepath for custom pngs

  NavItem({required this.title, required this.icon});
}

class NavManager extends ChangeNotifier {
  int _currentIndex = 0;
  
  final List<NavItem> items = [
    NavItem(title: 'Home', icon: Icons.home_outlined), // home
    NavItem(title: 'Agenda', icon: Icons.calendar_month), // agenda calendar_month
    NavItem(title: 'Weight', icon: Icons.scale_outlined), // scale scale_outlined
    NavItem(title: 'Exercises', icon: Icons.fitness_center), // dumbell fitness_center
    NavItem(title: 'Active', icon: Icons.play_circle_outline), // active workout play_circle_outline
    NavItem(title: 'Notes', icon: Icons.notes_outlined), // notes
  ];

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners(); // This tells the UI to rebuild
  }
}