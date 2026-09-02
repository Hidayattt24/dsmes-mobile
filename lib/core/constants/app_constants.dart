abstract final class AppConstants {
  AppConstants._();

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String baseUrl = String.fromEnvironment('BASE_URL');

  static String get requiredBaseUrl {
    if (baseUrl.trim().isEmpty) {
      throw StateError(
        'BASE_URL is not configured. Run with --dart-define=BASE_URL=<url>.',
      );
    }
    return baseUrl;
  }

  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyUserId = 'user_id';
  static const String keyBiometricEnabled = 'biometric_enabled';

  static const int totalOnboardingSteps = 19;

  static const int defaultPageSize = 20;

  static const int passwordMinLength = 8;
  static const double weightMin = 20.0;
  static const double weightMax = 300.0;
  static const double heightMin = 50.0;
  static const double heightMax = 250.0;

  static const List<String> bloodTypes = ['A', 'B', 'AB', 'O', 'Tidak Tahu'];
}
