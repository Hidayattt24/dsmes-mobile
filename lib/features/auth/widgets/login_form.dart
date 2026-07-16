import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
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
          // ── Email ────────────────────────────────────────────────────────
          Text(
            AppStrings.loginEmail.toUpperCase(),
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surfaceContainerLowest,
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.mail_outline, color: AppColors.outline, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: notifier.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.onBackground,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'Masukkan email Anda',
                      hintStyle: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.outlineVariant,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: notifier.validateEmail,
                    onChanged: notifier.onEmailChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Password ─────────────────────────────────────────────────────
          Text(
            AppStrings.loginPassword.toUpperCase(),
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surfaceContainerLowest,
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.lock_outline, color: AppColors.outline, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: notifier.passwordController,
                    obscureText: !state.isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.onBackground,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'Masukkan kata sandi',
                      hintStyle: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.outlineVariant,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: notifier.validatePassword,
                    onChanged: notifier.onPasswordChanged,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    state.isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.outline,
                    size: 22,
                  ),
                  onPressed: notifier.togglePasswordVisibility,
                  tooltip: state.isPasswordVisible
                      ? 'Sembunyikan kata sandi'
                      : 'Tampilkan kata sandi',
                ),
              ],
            ),
          ),

          // ── Error message ─────────────────────────────────────────────────
          if (state.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.error),
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
