import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

/// AccountCreatedSuccessScreen acts as the final onboarding completion page.
///
/// Pure frontend/UI implementation celebrating successful profile and routine setup.
class AccountCreatedSuccessScreen extends StatefulWidget {
  const AccountCreatedSuccessScreen({super.key});

  @override
  State<AccountCreatedSuccessScreen> createState() => _AccountCreatedSuccessScreenState();
}

class _AccountCreatedSuccessScreenState extends State<AccountCreatedSuccessScreen>
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
      duration: const Duration(milliseconds: 1000),
    );

    // Staggered animation values
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
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
                padding: const EdgeInsets.only(
                  left: AppSpacing.page,
                  right: AppSpacing.page,
                  top: AppSpacing.lg,
                  bottom: AppSpacing.xs,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Success Illustration
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildSuccessIllustration(),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Animated Title, Subtitle and Features Card
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
                                AppStrings.successTitle,
                                style: AppTextStyles.poppinsHeadline.copyWith(
                                  fontSize: 28,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                child: Text(
                                  AppStrings.successSubtitle,
                                  style: AppTextStyles.bodyLg.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),

                              // Features Information Card
                              AppCard(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Column(
                                  children: [
                                    _buildInfoItem(
                                      icon: Icons.calendar_today_outlined,
                                      title: AppStrings.successFeatureRoutineTitle,
                                      description: AppStrings.successFeatureRoutineDesc,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                                      child: Divider(
                                        color: AppColors.surfaceContainerHigh,
                                        height: 1,
                                      ),
                                    ),
                                    _buildInfoItem(
                                      icon: Icons.person_outline_rounded,
                                      title: AppStrings.successFeatureProfileTitle,
                                      description: AppStrings.successFeatureProfileDesc,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                                      child: Divider(
                                        color: AppColors.surfaceContainerHigh,
                                        height: 1,
                                      ),
                                    ),
                                    _buildInfoItem(
                                      icon: Icons.water_drop_outlined,
                                      title: AppStrings.successFeatureBloodSugarTitle,
                                      description: AppStrings.successFeatureBloodSugarDesc,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                                      child: Divider(
                                        color: AppColors.surfaceContainerHigh,
                                        height: 1,
                                      ),
                                    ),
                                    _buildInfoItem(
                                      icon: Icons.auto_stories_outlined,
                                      title: AppStrings.successFeatureEducationTitle,
                                      description: AppStrings.successFeatureEducationDesc,
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

            // Animated Bottom Button
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value * 0.5),
                    child: child,
                  ),
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
                    label: AppStrings.successButton,
                    onPressed: () {
                      context.go(RouteNames.home);
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

  Widget _buildSuccessIllustration() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.onSecondaryContainer,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSecondaryContainer.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.onPrimary,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                description,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
