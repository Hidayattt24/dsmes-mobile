/// Named route constants for DSMES Aceh.
/// Use these constants with GoRouter — never hardcode path strings.
abstract final class RouteNames {
  RouteNames._();

  // ── Paths ──────────────────────────────────────────────────────────────────
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  /// Signup entry = first onboarding step
  static const String signup = '/onboarding/1';

  static const String home = '/home';
  static const String dailyRoutineSetup = '/daily-routine-setup';
  static const String accountCreatedSuccess = '/account-created-success';
  static const String notifications = '/notifications';
  static const String bloodSugarEntry = '/blood-sugar-entry';
  static const String reminders = '/reminders';

  // ── Onboarding steps ───────────────────────────────────────────────────────
  static String onboardingStep(int step) => '/onboarding/$step';

  // ── Named route identifiers ────────────────────────────────────────────────
  static const String nameWelcome = 'welcome';
  static const String nameLogin = 'login';
  static const String nameForgotPassword = 'forgot-password';
  static const String nameOnboarding = 'onboarding';
  static const String nameHome = 'home';
  static const String nameDailyRoutineSetup = 'daily-routine-setup';
  static const String nameAccountCreatedSuccess = 'account-created-success';
  static const String nameNotifications = 'notifications';
  static const String nameBloodSugarEntry = 'blood-sugar-entry';
  static const String nameReminders = 'reminders';
  static const String mealEntry = '/meal-entry';
  static const String nameMealEntry = 'meal-entry';
}
