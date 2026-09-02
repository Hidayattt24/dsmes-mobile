import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../navigation/app_navigation_destinations.dart';
import 'app_navigation_item.dart';

/// Reusable AppBottomNavigation widget which accepts index and tap callbacks.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      borderOnForeground: true,
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: List.generate(appNavigationDestinations.length, (index) {
              final destination = appNavigationDestinations[index];
              return AppNavigationItem(
                icon: destination.icon,
                selectedIcon: destination.selectedIcon,
                label: destination.label,
                isSelected: selectedIndex == index,
                onTap: () => onDestinationSelected(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}
