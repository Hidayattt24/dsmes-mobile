import 'package:flutter/material.dart';

/// Data class representing a single destination item in the custom AppBottomNavigation.
class AppNavigationDestination {
  const AppNavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
