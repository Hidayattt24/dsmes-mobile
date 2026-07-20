import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
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
          // Elegant top-left to bottom-right gradient background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryContainer.withValues(alpha: 0.05),
                    AppColors.secondaryContainer.withValues(alpha: 0.02),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          
          // Medical grid dots background
          Positioned.fill(
            child: CustomPaint(
              painter: _MedicalGridPainter(),
            ),
          ),

          // Ambient glowing shapes
          Positioned(
            top: -60,
            right: -60,
            child: _BlurBlob(
              color: AppColors.primaryFixedDim.withValues(alpha: 0.15),
              size: 260,
            ),
          ),
          Positioned(
            bottom: 60,
            left: -80,
            child: _BlurBlob(
              color: AppColors.secondaryFixedDim.withValues(alpha: 0.12),
              size: 280,
            ),
          ),
          Positioned(
            top: 280,
            right: -100,
            child: _BlurBlob(
              color: AppColors.tertiaryFixedDim.withValues(alpha: 0.05),
              size: 240,
            ),
          ),

          // Glass blur overlay for blobs
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
              child: const SizedBox.shrink(),
            ),
          ),

          // Main scrollable content
          SafeArea(
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
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xl,
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
                      const SizedBox(height: AppSpacing.md),
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
}

// ── Medical Grid Painter ───────────────────────────────────────────────────

class _MedicalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryContainer.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const dotSize = 1.2;
    const spacing = 26.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Blur Ambient Blob ───────────────────────────────────────────────────────

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
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
        // Branding badge + title
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryContainer.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: AppColors.primaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'DSMES ACEH',
              style: AppTextStyles.poppinsHeadline.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryContainer,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppStrings.loginTitle,
          style: AppTextStyles.poppinsHeadline.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.loginSubtitle,
          style: AppTextStyles.bodyLg.copyWith(
            color: AppColors.outline,
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
                    color: isRemembered
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isRemembered
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      width: 1.8,
                    ),
                  ),
                  child: isRemembered
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
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.outline,
          ),
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
            '© 2026 Digital DSMES',
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
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Kebijakan Privasi',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.outline.withValues(alpha: 0.6),
                      fontSize: 12,
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
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Syarat & Ketentuan',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.outline.withValues(alpha: 0.6),
                      fontSize: 12,
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
