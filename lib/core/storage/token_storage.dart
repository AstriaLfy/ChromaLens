import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/colorblind_test/domain/entities/test_result_entity.dart';

class TokenStorage {
  final SharedPreferences _prefs;

  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyConditionType = 'user_condition_type';
  static const String _keyConditionDescription = 'user_condition_description';
  static const String _keyLastTestResult = 'user_last_test_result';

  TokenStorage(this._prefs);

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _prefs.setString(_keyAccessToken, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _prefs.setString(_keyRefreshToken, refreshToken);
    }
  }

  String? getAccessToken() {
    return _prefs.getString(_keyAccessToken);
  }

  String? getRefreshToken() {
    return _prefs.getString(_keyRefreshToken);
  }

  bool hasAccessToken() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveUserData({
    int? id,
    String? name,
    String? email,
  }) async {
    if (id != null) await _prefs.setInt(_keyUserId, id);
    if (name != null) await _prefs.setString(_keyUserName, name);
    if (email != null) await _prefs.setString(_keyUserEmail, email);
  }

  String? getUserEmail() => _prefs.getString(_keyUserEmail);
  String? getUserName() => _prefs.getString(_keyUserName);
  int? getUserId() => _prefs.getInt(_keyUserId);

  Map<String, dynamic>? getUserData() {
    final email = getUserEmail();
    if (email == null) return null;
    return {
      'id': getUserId(),
      'name': getUserName(),
      'email': email,
    };
  }

  Future<void> saveCondition({
    required String type,
    required String description,
    String? email,
  }) async {
    await _prefs.setString(_keyConditionType, type);
    await _prefs.setString(_keyConditionDescription, description);

    final userEmail = (email != null && email.isNotEmpty) ? email : getUserEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      await _prefs.setBool('condition_completed_$userEmail', true);
      await _prefs.setString('user_condition_type_$userEmail', type);
      await _prefs.setString('user_condition_desc_$userEmail', description);
    }
  }

  bool hasCompletedCondition({String? email}) {
    final userEmail = (email != null && email.isNotEmpty) ? email : getUserEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      final completed = _prefs.getBool('condition_completed_$userEmail');
      if (completed == true) return true;
      final savedType = _prefs.getString('user_condition_type_$userEmail');
      if (savedType != null && savedType.isNotEmpty) return true;
    }
    final condition = getConditionType();
    return condition != null && condition.isNotEmpty;
  }

  Future<void> restoreUserSession(String email) async {
    final savedType = _prefs.getString('user_condition_type_$email');
    final savedDesc = _prefs.getString('user_condition_desc_$email');
    final savedResult = _prefs.getString('user_test_result_$email');

    if (savedType != null && savedType.isNotEmpty) {
      await _prefs.setString(_keyConditionType, savedType);
    }
    if (savedDesc != null && savedDesc.isNotEmpty) {
      await _prefs.setString(_keyConditionDescription, savedDesc);
    }
    if (savedResult != null && savedResult.isNotEmpty) {
      await _prefs.setString(_keyLastTestResult, savedResult);
    }
  }

  String? getConditionType() => _prefs.getString(_keyConditionType);
  String? getConditionDescription() =>
      _prefs.getString(_keyConditionDescription);

  Future<void> saveTestResult(TestResultEntity result, {String? email}) async {
    final jsonStr = jsonEncode(result.toJson());
    await _prefs.setString(_keyLastTestResult, jsonStr);

    final userEmail = (email != null && email.isNotEmpty) ? email : getUserEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      await _prefs.setString('user_test_result_$userEmail', jsonStr);
    }

    await saveCondition(
      type: result.diagnosis,
      description: result.description,
      email: userEmail,
    );
  }

  TestResultEntity? getTestResult({String? email}) {
    final userEmail = (email != null && email.isNotEmpty) ? email : getUserEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      final rawUser = _prefs.getString('user_test_result_$userEmail');
      if (rawUser != null && rawUser.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawUser) as Map<String, dynamic>;
          return TestResultEntity.fromJson(decoded);
        } catch (_) {}
      }
    }

    final raw = _prefs.getString(_keyLastTestResult);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return TestResultEntity.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearTokens() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyConditionType);
    await _prefs.remove(_keyConditionDescription);
    await _prefs.remove(_keyLastTestResult);
  }
}
