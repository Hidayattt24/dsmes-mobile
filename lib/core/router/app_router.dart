import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell/app_shell.dart';
import '../../features/auth/views/forgot_password_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/home/blood_sugar/views/blood_sugar_entry_screen.dart';
import '../../features/home/reminders/views/reminders_management_screen.dart';
import '../../features/notifications/views/notifications_screen.dart';
import '../../features/onboarding/views/account_created_success_screen.dart';
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

    // ── Account Created Successfully ─────────────────────────────────────
    GoRoute(
      path: RouteNames.accountCreatedSuccess,
      name: RouteNames.nameAccountCreatedSuccess,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const AccountCreatedSuccessScreen(),
      ),
    ),

    // ── Home ─────────────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.home,
      name: RouteNames.nameHome,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const AppShell(),
      ),
    ),

    // ── Notifications ──────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.notifications,
      name: RouteNames.nameNotifications,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const NotificationsScreen(),
      ),
    ),

    // ── Blood Sugar Entry ──────────────────────────────────────────────
    GoRoute(
      path: RouteNames.bloodSugarEntry,
      name: RouteNames.nameBloodSugarEntry,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const BloodSugarEntryScreen(),
      ),
    ),

    // ── Reminders Management ───────────────────────────────────────────
    GoRoute(
      path: RouteNames.reminders,
      name: RouteNames.nameReminders,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const RemindersManagementScreen(),
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
