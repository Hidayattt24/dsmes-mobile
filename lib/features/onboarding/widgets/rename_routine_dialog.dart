import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

class RenameRoutineDialog extends StatefulWidget {
  const RenameRoutineDialog({super.key, required this.currentName});

  final String currentName;

  static Future<String?> show(BuildContext context, String currentName) {
    return showDialog<String>(
      context: context,
      builder: (_) => RenameRoutineDialog(currentName: currentName),
    );
  }

  @override
  State<RenameRoutineDialog> createState() => _RenameRoutineDialogState();
}

class _RenameRoutineDialogState extends State<RenameRoutineDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.currentName.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      title: Text(
        AppStrings.routineRenameTitle,
        style: AppTextStyles.headlineMd.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: AppTextStyles.bodyLg.copyWith(
          color: AppColors.onSurface,
        ),
        decoration: const InputDecoration(
          hintText: AppStrings.dailyRoutineNameHint,
          border: OutlineInputBorder(
            borderRadius: AppRadius.button,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.button,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppStrings.labelCancel,
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: Text(
            AppStrings.labelSave,
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
