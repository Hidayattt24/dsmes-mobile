import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell/app_shell.dart';
import '../../features/ai_chat/views/ai_chatbot_screen.dart';
import '../../features/auth/views/forgot_password_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/education/views/education_detail_screen.dart';
import '../../features/home/blood_sugar/views/blood_sugar_entry_screen.dart';
import '../../features/home/meal/views/meal_entry_screen.dart';
import '../../features/home/reminders/views/reminders_management_screen.dart';
import '../../features/notifications/views/notifications_screen.dart';
import '../../features/onboarding/views/account_created_success_screen.dart';
import '../../features/onboarding/views/daily_routine_setup_screen.dart';
import '../../features/onboarding/views/onboarding_flow_screen.dart';
import '../../features/onboarding/views/registration_welcome_screen.dart';
import '../../features/questionnaire/viewmodels/questionnaire_notifier.dart';
import '../../features/questionnaire/views/pre_test_intro_screen.dart';
import '../../features/settings/views/about_screen.dart';
import '../../features/settings/views/edit_body_metrics_screen.dart';
import '../../features/settings/views/help_center_screen.dart';
import '../../features/settings/views/personal_information_screen.dart';
import '../../features/settings/views/recalculate_result_screen.dart';
import '../../features/settings/views/security_privacy_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/welcome/views/welcome_screen.dart';
import '../constants/app_constants.dart';
import 'route_names.dart';

/// Routes that do NOT require Pre-Test completion.
const _publicRoutes = <String>{
  RouteNames.welcome,
  RouteNames.login,
  RouteNames.forgotPassword,
  RouteNames.registrationWelcome,
  RouteNames.dailyRoutineSetup,
  RouteNames.preTestIntro,
  RouteNames.accountCreatedSuccess,
};

/// DSMES Aceh App Router.
///
/// Configured via GoRouter with:
/// - Named routes for type-safe navigation
/// - Slide page transitions
/// - Redirect guard to enforce mandatory Pre-Test before accessing /home
///
/// Provided as a Riverpod [Provider] so that redirects can watch
/// [hasCompletedPreTestProvider] and call [GoRouter.refresh] when
/// pre-test state changes.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: RouteNames.welcome,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final preTestAsync = ref.read(hasCompletedPreTestProvider);

      final location = state.uri.toString();

      final isOnboarding = location.startsWith('/onboarding/');
      if (_publicRoutes.contains(location) || isOnboarding) return null;

      final completed = preTestAsync.valueOrNull;
      if (completed == null) return null;

      if (!completed) return RouteNames.preTestIntro;

      return null;
    },
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
    GoRoute(
      path: RouteNames.registrationWelcome,
      name: 'registration-welcome',
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const RegistrationWelcomeScreen(),
      ),
    ),

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

    // ── Pre-Test Intro (mandatory after Daily Routine Setup) ────────────
    GoRoute(
      path: RouteNames.preTestIntro,
      name: RouteNames.namePreTestIntro,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const PreTestIntroScreen(),
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

    // ── Meal Entry ────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.mealEntry,
      name: RouteNames.nameMealEntry,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const MealEntryScreen(),
      ),
    ),

    // ── Education Detail ─────────────────────────────────────────────────
    GoRoute(
      path: '${RouteNames.educationDetail}/:id',
      name: RouteNames.nameEducationDetail,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? 'art_featured';
        return _buildSlideTransition(
          state: state,
          child: EducationDetailScreen(articleId: id),
        );
      },
    ),

    // ── Settings ─────────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.settings,
      name: RouteNames.nameSettings,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.editBodyMetrics,
      name: RouteNames.nameEditBodyMetrics,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const EditBodyMetricsScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.recalculateResult,
      name: RouteNames.nameRecalculateResult,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const RecalculateResultScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.personalInformation,
      name: RouteNames.namePersonalInformation,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const PersonalInformationScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.securityPrivacy,
      name: RouteNames.nameSecurityPrivacy,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const SecurityPrivacyScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.helpCenter,
      name: RouteNames.nameHelpCenter,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const HelpCenterScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.about,
      name: RouteNames.nameAbout,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const AboutScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.aiChat,
      name: RouteNames.nameAiChat,
      pageBuilder: (context, state) => _buildSlideTransition(
        state: state,
        child: const AiChatbotScreen(),
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

  ref.listen(hasCompletedPreTestProvider, (_, __) => router.refresh());

  return router;
});

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
