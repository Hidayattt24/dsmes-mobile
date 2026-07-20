import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../viewmodels/login_notifier.dart';

class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(loginProvider.notifier);
    final state = ref.watch(loginProvider);

    return Form(
      key: notifier.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Field
          AppTextField(
            label: AppStrings.loginEmail,
            hint: AppStrings.loginEmailHint,
            controller: notifier.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.email_outlined,
            autofillHints: const [AutofillHints.email],
            semanticLabel: 'Kolom input email',
            validator: notifier.validateEmail,
            onChanged: notifier.onEmailChanged,
          ),
          const SizedBox(height: AppSpacing.md),

          // Password Field
          AppTextField(
            label: AppStrings.loginPassword,
            hint: AppStrings.loginPasswordHint,
            controller: notifier.passwordController,
            isPassword: true,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline,
            autofillHints: const [AutofillHints.password],
            semanticLabel: 'Kolom input kata sandi',
            validator: notifier.validatePassword,
            onChanged: notifier.onPasswordChanged,
          ),

          // API Error banner
          if (state.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
