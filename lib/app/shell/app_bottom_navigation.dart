import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../navigation/app_navigation_destinations.dart';
import 'app_navigation_item.dart';

/// Reusable AppBottomNavigation widget which accepts index and tap callbacks.
///
/// Implements the floating layout, styling, colors, and shadows.
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xs,
        AppSpacing.page,
        AppSpacing.sm + bottomPadding,
      ),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest, // white
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadows.medium,
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    );
  }
}
