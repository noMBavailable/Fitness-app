import 'package:flutter/material.dart';

// --- DATA STRUCTURE ---
// Simple holding model representing an individual clickable tab node within the lower menu bar
class NavItem {
  final String title; // The written text description label appearing underneath navigation icons
  final IconData icon; // The visual graphics glyph configuration linked directly to this target button

  NavItem({required this.title, required this.icon});
}

class NavManager extends ChangeNotifier {
  // Global reference key pointer tracking which app workspace screen track is currently operational
  int _currentIndex = 0;
  
  // Static array establishing the ordering positions of the horizontal dock options bar grid layout
  final List<NavItem> items = [
    NavItem(title: 'Home', icon: Icons.home_outlined),
    NavItem(title: 'Agenda', icon: Icons.calendar_month),
    NavItem(title: 'Weight', icon: Icons.scale_outlined),
    NavItem(title: 'Exercises', icon: Icons.fitness_center),
    NavItem(title: 'Active', icon: Icons.play_circle_outline),
    NavItem(title: 'Notes', icon: Icons.notes_outlined),
  ];

  // Public state getter exposing index values to external framework interface modules layers
  int get currentIndex => _currentIndex;

  // --- TRANSITION CONTROLLER ---
  // Modifies active dashboard position tracking variables and alerts layout widgets listeners
  void setIndex(int index) {
    if (_currentIndex == index) return; // Optimization: Skip redraw updates loops if clicking the active focused tab
    
    _currentIndex = index;
    notifyListeners(); // Force instant structural navigation updates across main display screens frame containers
  }
}