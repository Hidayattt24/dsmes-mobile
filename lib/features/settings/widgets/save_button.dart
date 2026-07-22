import 'package:flutter/material.dart';
import '../../../core/widgets/app_button.dart';

/// Reusable Save Button for submitting updated body metrics.
class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.onPressed,
    this.label = 'Simpan & Hitung Ulang',
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: Icons.calculate_rounded,
    );
  }
}
