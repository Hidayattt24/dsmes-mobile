import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

/// RegistrationWelcomeScreen displayed right after Step 6 (Account Registration).
///
/// Welcomes the newly registered user and prompts them to complete their health profile.
class RegistrationWelcomeScreen extends StatefulWidget {
  const RegistrationWelcomeScreen({super.key});

  @override
  State<RegistrationWelcomeScreen> createState() =>
      _RegistrationWelcomeScreenState();
}

class _RegistrationWelcomeScreenState extends State<RegistrationWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                  vertical: AppSpacing.xl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSpacing.xxl),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildWelcomeIcon(),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                "Selamat datang di DSMES Aceh!",
                                style: AppTextStyles.poppinsHeadline.copyWith(
                                  fontSize: 26,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                "Akun Anda telah berhasil dibuat. Langkah selanjutnya adalah melengkapi profil kesehatan Anda agar aplikasi dapat memberikan rekomendasi nutrisi & edukasi yang paling tepat.",
                                style: AppTextStyles.bodyLg.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(
                                    color: AppColors.primaryContainer
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.health_and_safety_outlined,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Langkah 2: Profil Kesehatan",
                                            style: AppTextStyles.labelLg
                                                .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: AppSpacing.xxs),
                                          Text(
                                            "Memperhitung BMR, TDEE & Target Kalori Harian Anda",
                                            style: AppTextStyles.bodyMd
                                                .copyWith(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                );
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.md,
                  AppSpacing.page,
                  AppSpacing.lg + bottomPadding,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.surfaceContainerHigh,
                      width: 1,
                    ),
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: AppButton(
                    label: "Lanjut Lengkapi Profil",
                    onPressed: () {
                      context.go('/onboarding/7');
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: AppColors.onPrimary,
            size: 48,
          ),
        ),
      ),
    );
  }
}
