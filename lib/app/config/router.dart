import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/verify_code_screen.dart';
import '../../features/camera/presentation/screens/camera_permission_denied_screen.dart';
import '../../features/camera/presentation/screens/camera_screen.dart';
import '../../features/colorblind_test/domain/entities/test_result_entity.dart';
import '../../features/colorblind_test/presentation/screens/colorblind_test_screen.dart';
import '../../features/colorblind_test/presentation/screens/test_result_screen.dart';
import '../../features/navigation/presentation/screens/main_navigation_shell.dart';
import '../../features/select_condition/presentation/screens/select_condition_screen.dart';

import '../../core/di/injection_container.dart';
import '../../core/storage/token_storage.dart';
import '../../features/profile/domain/entities/user_profile_entity.dart';
import '../../features/profile/presentation/screens/profile_test_result_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';
  static const String verifyCode = '/verify_code';
  static const String resetPassword = '/reset_password';
  static const String selectCondition = '/select_condition';
  static const String colorblindTest = '/colorblind_test';
  static const String testResult = '/test_result';
  static const String home = '/home';
  static const String camera = '/camera';
  static const String cameraDenied = '/camera_permission_denied';
  static const String profile = '/profile';
  static const String profileTestResult = '/profile_test_result';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case verifyCode:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(email: email),
          settings: settings,
        );
      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: args['email'] as String? ?? '',
            code: args['code'] as String? ?? '',
          ),
          settings: settings,
        );
      case selectCondition:
        return MaterialPageRoute(
          builder: (_) => const SelectConditionScreen(),
          settings: settings,
        );
      case colorblindTest:
        return MaterialPageRoute(
          builder: (_) => const ColorblindTestScreen(),
          settings: settings,
        );
      case testResult:
        final result = settings.arguments as TestResultEntity? ??
            sl<TokenStorage>().getTestResult() ??
            TestResultEntity(
              diagnosis: sl<TokenStorage>().getConditionType() ?? 'Penglihatan Normal',
              description: sl<TokenStorage>().getConditionDescription() ??
                  'Penglihatan warna Anda normal pada seluruh spektrum warna.',
              affectedColors: 'Tidak Ada',
              category: 'Normal Vision',
              testDate: DateTime.now(),
              correctCount: 12,
              totalQuestions: 12,
            );
        return MaterialPageRoute(
          builder: (_) => TestResultScreen(result: result),
          settings: settings,
        );
      case home:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final isOffline = args['offline'] as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => MainNavigationShell(isOfflineMode: isOffline),
          settings: settings,
        );
      case camera:
        return MaterialPageRoute(
          builder: (_) => const CameraScreen(),
          settings: settings,
        );
      case cameraDenied:
        return MaterialPageRoute(
          builder: (ctx) => CameraPermissionDeniedScreen(
            onRetry: () {
              Navigator.pop(ctx);
            },
          ),
          settings: settings,
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationShell(initialTab: 2),
          settings: settings,
        );
      case profileTestResult:
        TestResultEntity? testResult;
        UserProfileEntity? userProfile;
        if (settings.arguments is TestResultEntity) {
          testResult = settings.arguments as TestResultEntity;
        } else if (settings.arguments is UserProfileEntity) {
          userProfile = settings.arguments as UserProfileEntity;
        } else if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          testResult = args['testResult'] as TestResultEntity?;
          userProfile = args['profile'] as UserProfileEntity?;
        }
        return MaterialPageRoute(
          builder: (_) => ProfileTestResultScreen(
            testResult: testResult,
            userProfile: userProfile,
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
    }
  }
}
