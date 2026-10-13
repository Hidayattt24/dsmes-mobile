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
/// resolved. Once resolved it routes the user smoothly to Home (if the Pre-Test is done)
/// or to the Pre-Test intro (if it is still required).
class SplashGateScreen extends ConsumerStatefulWidget {
  const SplashGateScreen({super.key});

  @override
  ConsumerState<SplashGateScreen> createState() => _SplashGateScreenState();
}

class _SplashGateScreenState extends ConsumerState<SplashGateScreen> {
  DateTime? _initTime;
  static const _minSplashDuration = Duration(milliseconds: 1100);
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initTime = DateTime.now();
  }

  void _navigateSmoothly(String route) {
    if (_isNavigating) return;
    _isNavigating = true;

    final elapsed = DateTime.now().difference(_initTime ?? DateTime.now());
    final remaining = _minSplashDuration - elapsed;

    Future.delayed(
      remaining.isNegative ? Duration.zero : remaining,
      () {
        if (mounted &&
            GoRouterState.of(context).matchedLocation == RouteNames.splash) {
          context.go(route);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionRestoreProvider);

    sessionAsync.when(
      skipLoadingOnReload: false,
      skipLoadingOnRefresh: false,
      loading: () {},
      error: (_, _) => _navigateSmoothly(RouteNames.welcome),
      data: (loggedIn) {
        if (!loggedIn) {
          _navigateSmoothly(RouteNames.welcome);
          return;
        }
        // Only watch questionnaire eligibility after session is confirmed restored
        ref.watch(hasCompletedPreTestProvider).when(
              skipLoadingOnReload: false,
              skipLoadingOnRefresh: false,
              loading: () {},
              error: (_, _) => _navigateSmoothly(RouteNames.preTestIntro),
              data: (completed) => _navigateSmoothly(
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
      child: Stack(
        children: [
          // Center: Logo and loading indicator perfectly grouped at the exact center
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Image.asset(
                      'assets/images/splash_logo.png',
                      width: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Footer Tagline
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: FadeTransition(
              opacity: _fade,
              child: Text(
                'Diabetes Self-Management Education & Support',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSm.copyWith(
                  color: const Color(0xFF718096),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
