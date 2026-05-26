import 'package:flutter/material.dart';

/// Provider untuk state navigasi bottom bar.
/// Menggantikan NavigationController agar konsisten
/// dengan naming convention Provider pattern.
class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  /// Langsung lompat ke tab tertentu (misal: dari Dashboard ke Explore)
  void jumpToTab(int index) => setIndex(index);

  /// Shortcut ke tab Explore (index 1)
  void goToExplore() => setIndex(1);

  /// Shortcut ke tab Library (index 2)
  void goToLibrary() => setIndex(2);

  /// Shortcut ke tab Profile (index 3)
  void goToProfile() => setIndex(3);
}
