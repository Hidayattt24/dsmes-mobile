import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';

/// Forgot Password screen — placeholder UI.
///
/// TODO: Wire to AuthRepository when backend is ready.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationRequired;
    }
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.validationEmail;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: Call AuthRepository.forgotPassword()
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      AppSnackbar.showSuccess(
        context,
        AppStrings.forgotPasswordSuccessMessage,
      );
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
                _ForgotPasswordHeader(),
                const SizedBox(height: AppSpacing.xl),
                Form(
                  key: _formKey,
                  child: AppTextField(
                    label: AppStrings.forgotPasswordEmail,
                    hint: AppStrings.forgotPasswordEmailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.email_outlined,
                    semanticLabel: 'Kolom email',
                    validator: _validateEmail,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: AppStrings.forgotPasswordButton,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: Text(
                      AppStrings.forgotPasswordBackToLogin,
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordHeader extends StatelessWidget {
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
          AppStrings.forgotPasswordTitle,
          style: AppTextStyles.poppinsHeadline,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          AppStrings.forgotPasswordSubtitle,
          style: AppTextStyles.bodyMd
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
