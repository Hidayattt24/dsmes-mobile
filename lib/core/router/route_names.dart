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
  static const String educationDetail = '/education-detail';
  static const String nameEducationDetail = 'education-detail';
  static const String questionnaireDetail = '/questionnaire-detail';
  static const String nameQuestionnaireDetail = 'questionnaire-detail';
  static const String questionnaireResult = '/questionnaire-result';
  static const String nameQuestionnaireResult = 'questionnaire-result';
  static const String settings = '/settings';
  static const String nameSettings = 'settings';
  static const String editBodyMetrics = '/edit-body-metrics';
  static const String nameEditBodyMetrics = 'edit-body-metrics';
  static const String recalculateResult = '/recalculate-result';
  static const String nameRecalculateResult = 'recalculate-result';
  static const String personalInformation = '/personal-information';
  static const String namePersonalInformation = 'personal-information';
  static const String reminderSettings = '/reminder-settings';
  static const String nameReminderSettings = 'reminder-settings';
  static const String securityPrivacy = '/security-privacy';
  static const String nameSecurityPrivacy = 'security-privacy';
  static const String helpCenter = '/help-center';
  static const String nameHelpCenter = 'help-center';
  static const String about = '/about';
  static const String nameAbout = 'about';
}
