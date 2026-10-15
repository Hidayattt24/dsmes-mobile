import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../viewmodels/login_notifier.dart';
import '../widgets/login_form.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        child: AutofillGroup(
          child: GestureDetector(
            onTap: FocusScope.of(context).unfocus,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  // Header Section
                  _LoginHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  // Login card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xl,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: AppRadius.card,
                      border: Border.all(color: const Color(0xFFD9E1EF)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x143B67FC),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Form
                        const LoginForm(),
                        const SizedBox(height: AppSpacing.md),
                        // Remember me & Forgot password
                        _LoginOptions(
                          isRemembered: state.isRemembered,
                          onToggleRemember: notifier.toggleRememberMe,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        // Submit button
                        AppButton(
                          label: AppStrings.loginButton,
                          isLoading: state.isLoading,
                          height: 54,
                          onPressed: () async {
                            final success = await notifier.submit();
                            if (context.mounted && success) {
                              context.go(RouteNames.home);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Sign up link
                        _SignUpRedirect(),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Footer
                  _LoginFooter(),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Branding logo
        Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/images/logo.png',
            height: 44,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppStrings.loginTitle,
          style: AppTextStyles.poppinsHeadline.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.onPrimaryFixed,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.loginSubtitle,
          style: AppTextStyles.bodyLg.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ── Options Row ────────────────────────────────────────────────────────────

class _LoginOptions extends StatelessWidget {
  const _LoginOptions({
    required this.isRemembered,
    required this.onToggleRemember,
  });

  final bool isRemembered;
  final VoidCallback onToggleRemember;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember me custom checkbox
        InkWell(
          onTap: onToggleRemember,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeIn,
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color:
                        isRemembered ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          isRemembered
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                      width: 1.8,
                    ),
                  ),
                  child:
                      isRemembered
                          ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: AppColors.onPrimary,
                          )
                          : null,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Ingat saya',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Forgot password link
        GestureDetector(
          onTap: () => context.push(RouteNames.forgotPassword),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              AppStrings.loginForgotPassword,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sign Up Redirect ───────────────────────────────────────────────────────

class _SignUpRedirect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.loginNoAccount,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
        ),
        GestureDetector(
          onTap: () => context.go(RouteNames.signup),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              AppStrings.loginSignUp,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
                decorationThickness: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Footer ─────────────────────────────────────────────────────────────────

class _LoginFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            '© 2026 DIBA (Diabetes Behaviour & Adherence Application)',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.outline.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => context.push(RouteNames.privacyPolicy),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Kebijakan Privasi',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.outline.withValues(alpha: 0.8),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '•',
                  style: TextStyle(
                    color: AppColors.outline.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push(RouteNames.termsConditions),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Syarat & Ketentuan',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.outline.withValues(alpha: 0.8),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
