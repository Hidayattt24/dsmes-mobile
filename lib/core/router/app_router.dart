import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/views/forgot_password_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/onboarding/views/daily_routine_setup_screen.dart';
import '../../features/onboarding/views/onboarding_flow_screen.dart';
import '../../features/welcome/views/welcome_screen.dart';
import '../constants/app_constants.dart';
import 'route_names.dart';

/// DSMES Aceh App Router.
///
/// Configured via GoRouter with:
/// - Named routes for type-safe navigation
/// - Slide page transitions
/// - Redirect logic placeholder for auth guard
///
/// Add [ProviderScope] aware redirect once auth state is wired.
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.welcome,
  debugLogDiagnostics: true,
  routes: [
    // ── Welcome ───────────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.welcome,
      name: RouteNames.nameWelcome,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const WelcomeScreen(),
      ),
    ),

    // ── Auth ──────────────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.login,
      name: RouteNames.nameLogin,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      name: RouteNames.nameForgotPassword,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const ForgotPasswordScreen(),
      ),
    ),

    // ── Onboarding ────────────────────────────────────────────────────────
    // Each step is a separate GoRoute for deep-linkability.
    for (int step = 1; step <= AppConstants.totalOnboardingSteps; step++)
      GoRoute(
        path: '/onboarding/$step',
        name: '${RouteNames.nameOnboarding}_$step',
        pageBuilder: (context, state) => _buildSlideTransition(
          state: state,
          child: OnboardingFlowScreen(step: step),
        ),
      ),

    // ── Daily Routine Setup ─────────────────────────────────────────────
    GoRoute(
      path: RouteNames.dailyRoutineSetup,
      name: RouteNames.nameDailyRoutineSetup,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const DailyRoutineSetupScreen(),
      ),
    ),

    // ── Home (placeholder) ───────────────────────────────────────────────
    GoRoute(
      path: RouteNames.home,
      name: RouteNames.nameHome,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const _HomePlaceholder(),
      ),
    ),
  ],

  // Error page
  errorPageBuilder: (context, state) => MaterialPage(
    child: Scaffold(
      body: Center(
        child: Text('Halaman tidak ditemukan: ${state.uri}'),
      ),
    ),
  ),
);

/// Slide-from-right page transition (consistent across all routes).
CustomTransitionPage<void> _buildSlideTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
  );
}

/// Temporary Home placeholder until Home feature is built.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_outlined, size: 64, color: Color(0xFF004f45)),
            const SizedBox(height: 16),
            Text(
              'Beranda',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Home screen akan diimplementasikan berikutnya.'),
          ],
        ),
      ),
    );
  }
}
