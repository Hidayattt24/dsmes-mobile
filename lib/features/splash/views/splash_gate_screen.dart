import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../questionnaire/viewmodels/questionnaire_notifier.dart';

/// Transient gate shown while the mandatory Pre-Test completion status is being
/// resolved. Once resolved it routes the user to Home (if the Pre-Test is done)
/// or to the Pre-Test intro (if it is still required).
///
/// This removes the previous "loading window" where a user could reach a
/// protected route (e.g. /home) before `hasCompletedPreTestProvider` resolved,
/// bypassing the mandatory Pre-Test.
class SplashGateScreen extends ConsumerWidget {
  const SplashGateScreen({super.key});

  void _goIfOnSplash(BuildContext context, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted &&
          GoRouterState.of(context).matchedLocation == RouteNames.splash) {
        context.go(route);
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionRestoreProvider);

    sessionAsync.when(
      loading: () {},
      error: (_, _) => _goIfOnSplash(context, RouteNames.welcome),
      data: (loggedIn) {
        if (!loggedIn) {
          _goIfOnSplash(context, RouteNames.welcome);
          return;
        }
        // Only watch questionnaire eligibility after session is confirmed restored
        ref.watch(hasCompletedPreTestProvider).when(
              loading: () {},
              error: (_, _) => _goIfOnSplash(context, RouteNames.preTestIntro),
              data: (completed) => _goIfOnSplash(
                context,
                completed ? RouteNames.home : RouteNames.preTestIntro,
              ),
            );
      },
    );

    // Always white, regardless of the system light/dark theme.
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _SplashContent(),
      ),
    );
  }
}

class _SplashContent extends StatefulWidget {
  const _SplashContent();

  @override
  State<_SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<_SplashContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<double> _scale = Tween<double>(begin: 0.85, end: 1)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(),
          FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Image.asset(
                'assets/images/splash_logo.png',
                width: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Spacer(),
          FadeTransition(
            opacity: _fade,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Diabetes Self-Management Education & Support',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSm.copyWith(
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
