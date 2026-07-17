import 'package:flutter/material.dart';

/// Representation of a tab destination in the custom Bottom Navigation Bar.
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

/// Centralized configuration list of Bottom Navigation destinations.
///
/// Any addition, deletion, or modification to tabs should only be made here.
const List<AppNavigationDestination> appNavigationDestinations = [
  AppNavigationDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Beranda',
  ),
  AppNavigationDestination(
    icon: Icons.monitor_heart_outlined,
    selectedIcon: Icons.monitor_heart_rounded,
    label: 'Catat',
  ),
  AppNavigationDestination(
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
    label: 'Edukasi',
  ),
  AppNavigationDestination(
    icon: Icons.quiz_outlined,
    selectedIcon: Icons.quiz_rounded,
    label: 'Kuesioner',
  ),
  AppNavigationDestination(
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    label: 'Profil',
  ),
];
