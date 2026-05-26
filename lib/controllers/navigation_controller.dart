import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  // Helper untuk navigasi langsung ke tab tertentu (misal: dari dashboard ke profil)
  void jumpToTab(int index) {
    setIndex(index);
  }
}
