abstract final class AppConstants {
  AppConstants._();

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyUserId = 'user_id';

  static const int totalOnboardingSteps = 13;

  static const int defaultPageSize = 20;

  static const int passwordMinLength = 8;
  static const double weightMin = 20.0;
  static const double weightMax = 300.0;
  static const double heightMin = 50.0;
  static const double heightMax = 250.0;

  static const List<String> bloodTypes = [
    'A',
    'B',
    'AB',
    'O',
    'Tidak Tahu',
  ];
}
