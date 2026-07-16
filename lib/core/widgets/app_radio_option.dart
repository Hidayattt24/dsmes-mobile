import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Reusable selectable card-style radio option.
///
/// Matches the HTML Step 11 (Activity Level) design:
/// - Card with border that highlights to primary when selected
/// - Title + description text
/// - Animated check circle icon
class AppRadioOption<T> extends StatelessWidget {
  const AppRadioOption({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    required this.onChanged,
    this.description,
    this.leadingIcon,
  });

  final T value;
  final T? groupValue;
  final String title;
  final String? description;
  final IconData? leadingIcon;
  final ValueChanged<T> onChanged;

  bool get _isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isSelected
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: _isSelected ? AppColors.primary : AppColors.outlineVariant,
          width: _isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.card,
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: AppRadius.card,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: _OptionContent(
                    title: title,
                    description: description,
                    isSelected: _isSelected,
                  ),
                ),
                _CheckIcon(isSelected: _isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionContent extends StatelessWidget {
  const _OptionContent({
    required this.title,
    this.description,
    required this.isSelected,
  });

  final String title;
  final String? description;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.poppinsButton.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 2),
          Text(
            description!,
            style: AppTextStyles.labelMd.copyWith(
              color: isSelected
                  ? AppColors.onPrimary.withValues(alpha: 0.85)
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _CheckIcon extends StatelessWidget {
  const _CheckIcon({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isSelected
          ? const Icon(
              Icons.check_circle,
              key: ValueKey('selected'),
              color: AppColors.onPrimary,
              size: 24,
            )
          : const Icon(
              Icons.circle_outlined,
              key: ValueKey('unselected'),
              color: AppColors.outlineVariant,
              size: 24,
            ),
    );
  }
}
