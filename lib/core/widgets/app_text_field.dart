import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable text field with label, hint, validation, and password toggle.
///
/// Uses theme tokens only. No business logic inside this widget.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.inputFormatters,
    this.autofillHints,
    this.focusNode,
    this.semanticLabel,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool isPassword;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.isPassword && _obscureText,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        maxLines: widget.isPassword ? 1 : widget.maxLines,
        inputFormatters: widget.inputFormatters,
        autofillHints: widget.autofillHints,
        focusNode: widget.focusNode,
        style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: AppColors.outline)
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.outline,
                  ),
                  tooltip: _obscureText
                      ? 'Tampilkan kata sandi'
                      : 'Sembunyikan kata sandi',
                  onPressed: _toggleObscureText,
                )
              : widget.suffixIcon,
        ),
      ),
    );
  }
}
