import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Medical grid background
          Positioned.fill(
            child: CustomPaint(
              painter: _MedicalGridPainter(),
            ),
          ),
          // Wave pattern decorations
          ..._buildWaveDecorations(),
          // Main content
          SafeArea(
            child: AutofillGroup(
              child: GestureDetector(
                onTap: FocusScope.of(context).unfocus,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      // Header
                      _LoginHeader(),
                      const SizedBox(height: AppSpacing.lg),
                      // Login card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A00695c),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Form
                            const LoginForm(),
                            const SizedBox(height: AppSpacing.sm),
                            // Remember me & Forgot password
                            _LoginOptions(
                              isRemembered: state.isRemembered,
                              onToggleRemember: notifier.toggleRememberMe,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Submit button
                            AppButton(
                              label: AppStrings.loginButton,
                              isLoading: state.isLoading,
                              height: 52,
                              borderRadius: BorderRadius.circular(14),
                              onPressed: () async {
                                await notifier.submit();
                                if (context.mounted &&
                                    state.errorMessage == null) {
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWaveDecorations() {
    return const [
      Positioned(
        top: -100,
        left: -50,
        width: 300,
        height: 300,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x0800695c),
          ),
        ),
      ),
      Positioned(
        bottom: -100,
        right: -50,
        width: 300,
        height: 300,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x0800695c),
          ),
        ),
      ),
    ];
  }
}

class _MedicalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryContainer.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const dotSize = 1.5;
    const spacing = 24.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Header ─────────────────────────────────────────────────────────────────

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Branding
        Row(
          children: [
            const Icon(
              Icons.local_hospital,
              color: AppColors.primaryContainer,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Digital DSMES',
              style: AppTextStyles.headlineMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryContainer,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppStrings.loginTitle,
          style: AppTextStyles.poppinsHeadline.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          AppStrings.loginSubtitle,
          style: AppTextStyles.bodyLg.copyWith(
            color: AppColors.outline,
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
        // Remember me
        InkWell(
          onTap: onToggleRemember,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isRemembered
                      ? AppColors.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isRemembered
                        ? AppColors.primaryContainer
                        : AppColors.outline,
                    width: 2,
                  ),
                ),
                child: isRemembered
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Ingat saya',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        // Forgot password
        GestureDetector(
          onTap: () => context.push(RouteNames.forgotPassword),
          child: Text(
            AppStrings.loginForgotPassword,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w500,
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
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.outline,
          ),
        ),
        GestureDetector(
          onTap: () => context.go(RouteNames.signup),
          child: Text(
            AppStrings.loginSignUp,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationThickness: 2,
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
    return Column(
      children: [
        Text(
          '© 2026 Digital DSMES',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.outline,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kebijakan Privasi',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.outlineVariant,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 4, height: 4),
              ),
            ),
            Text(
              'Syarat & Ketentuan',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.outlineVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
