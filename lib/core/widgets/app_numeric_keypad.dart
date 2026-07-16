import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Reusable custom numeric keypad for weight and height input.
///
/// Matches the HTML design for Steps 9 (height) and 10 (weight):
/// - 3-column grid of numeric keys
/// - Decimal support
/// - Backspace key
class AppNumericKeypad extends StatelessWidget {
  const AppNumericKeypad({
    super.key,
    required this.onKeyTapped,
    required this.onBackspace,
  });

  final ValueChanged<String> onKeyTapped;
  final VoidCallback onBackspace;

  static const List<String> _keys = [
    '1', '2', '3',
    '4', '5', '6',
    '7', '8', '9',
    ',', '0', '⌫',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.8,
      ),
      itemCount: _keys.length,
      itemBuilder: (context, index) {
        final key = _keys[index];
        return _KeypadButton(
          label: key,
          isBackspace: key == '⌫',
          onTap: () {
            if (key == '⌫') {
              onBackspace();
            } else if (key == ',') {
              onKeyTapped('.');
            } else {
              onKeyTapped(key);
            }
          },
        );
      },
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.onTap,
    required this.isBackspace,
  });

  final String label;
  final VoidCallback onTap;
  final bool isBackspace;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isBackspace ? 'Hapus' : label,
      child: Material(
        color: isBackspace
            ? AppColors.surfaceContainerLow
            : AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.cardMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardMd,
          splashColor: AppColors.primaryContainer.withValues(alpha: 0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardMd,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            alignment: Alignment.center,
            child: isBackspace
                ? const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.onSurface,
                    size: 28,
                  )
                : Text(
                    label,
                    style: AppTextStyles.numericDisplay.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Display widget for the current numeric value being entered.
class AppNumericDisplay extends StatelessWidget {
  const AppNumericDisplay({
    super.key,
    required this.value,
    required this.unit,
    this.placeholder = '0',
  });

  final String value;
  final String unit;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value.isEmpty ? placeholder : value,
            style: AppTextStyles.numericDisplay.copyWith(
              color: value.isEmpty ? AppColors.outline : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              unit,
              style: AppTextStyles.poppinsHeadline.copyWith(
                color: AppColors.secondary,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
