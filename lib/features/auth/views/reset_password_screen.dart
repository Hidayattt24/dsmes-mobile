import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/repositories/auth_repository.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String otpCode;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otpCode,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;


  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationRequired;
    }
    if (value.trim().length < 8) {
      return AppStrings.validationPasswordMin;
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationRequired;
    }
    if (value.trim() != _passwordController.text.trim()) {
      return AppStrings.validationPasswordNotMatch;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            email: widget.email,
            otpCode: widget.otpCode,
            newPassword: _passwordController.text.trim(),
            confirmPassword: _confirmController.text.trim(),
          );
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.showSuccess(
          context,
          AppStrings.resetPasswordSuccess,
        );
        context.go(RouteNames.login);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.showError(context, AppStrings.errorGeneral);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
          tooltip: 'Kembali',
        ),
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResetPasswordHeader(),
                const SizedBox(height: AppSpacing.xl),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        label: AppStrings.resetPasswordNewLabel,
                        hint: AppStrings.resetPasswordNewHint,
                        controller: _passwordController,
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.lock_outline,
                        semanticLabel: 'Kata sandi baru',
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: AppStrings.resetPasswordConfirmLabel,
                        hint: AppStrings.resetPasswordConfirmHint,
                        controller: _confirmController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.lock_outline,
                        semanticLabel: 'Konfirmasi kata sandi',
                        validator: _validateConfirm,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: AppStrings.resetPasswordButton,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetPasswordHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: const Icon(
            Icons.lock_reset_outlined,
            color: AppColors.onSecondaryContainer,
            size: 28,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppStrings.resetPasswordTitle,
          style: AppTextStyles.poppinsHeadline,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          AppStrings.resetPasswordSubtitle,
          style: AppTextStyles.bodyMd
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
