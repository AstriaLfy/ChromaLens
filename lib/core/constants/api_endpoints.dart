
class ApiEndpoints {
  ApiEndpoints._();

  static String? _customBaseUrl;

  /// Allows overriding base URL at runtime (e.g. for testing or staging)
  static void setBaseUrl(String url) {
    _customBaseUrl = url;
  }

  /// Base URL — uses ngrok tunnel for all platforms.
  /// Override at runtime with setBaseUrl() if needed.
  static String get baseUrl {
    if (_customBaseUrl != null) return _customBaseUrl!;
    return 'https://jaws-hurler-unranked.ngrok-free.dev';
  }

  // Auth Endpoints
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String googleLogin = '/api/v1/auth/google';
  static const String logout = '/api/v1/auth/logout';
  static const String refreshToken = '/api/v1/auth/refresh-token';

  // Password Reset Endpoints
  static const String forgotPassword = '/api/v1/auth/password/forgot';
  static const String verifyResetCode = '/api/v1/auth/password/verify-code';
  static const String resetPassword = '/api/v1/auth/password/reset';

  // User Endpoints
  static const String userProfile = '/api/v1/user/profile';
  static const String userSettings = '/api/v1/user/settings';
  static const String userCondition = '/api/v1/user/condition';

  // Test Endpoints
  static const String ishiharaPlates = '/api/v1/tests/ishihara/plates';
  static const String submitAnswers = '/api/v1/tests/ishihara/submit';
  static const String latestTestResult = '/api/v1/tests/latest';
  static const String testHistory = '/api/v1/tests/history';
}
