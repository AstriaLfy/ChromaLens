import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chroma_lens/core/storage/token_storage.dart';

void main() {
  late TokenStorage tokenStorage;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    tokenStorage = TokenStorage(prefs);
  });

  test('Initially has no tokens', () {
    expect(tokenStorage.hasAccessToken(), isFalse);
    expect(tokenStorage.getAccessToken(), isNull);
    expect(tokenStorage.getRefreshToken(), isNull);
    expect(tokenStorage.getUserData(), isNull);
  });

  test('saveTokens stores access and refresh tokens correctly', () async {
    await tokenStorage.saveTokens(
      accessToken: 'sample_access_jwt',
      refreshToken: 'sample_refresh_jwt',
    );

    expect(tokenStorage.hasAccessToken(), isTrue);
    expect(tokenStorage.getAccessToken(), 'sample_access_jwt');
    expect(tokenStorage.getRefreshToken(), 'sample_refresh_jwt');
  });

  test('saveUserData stores user profile and retrieves as map', () async {
    await tokenStorage.saveUserData(
      id: 42,
      name: 'Tester User',
      email: 'tester@chromalens.app',
    );

    expect(tokenStorage.getUserId(), 42);
    expect(tokenStorage.getUserName(), 'Tester User');
    expect(tokenStorage.getUserEmail(), 'tester@chromalens.app');

    final data = tokenStorage.getUserData();
    expect(data, isNotNull);
    expect(data!['id'], 42);
    expect(data['name'], 'Tester User');
    expect(data['email'], 'tester@chromalens.app');
  });

  test('clearTokens clears all stored tokens and user details', () async {
    await tokenStorage.saveTokens(
      accessToken: 'token123',
      refreshToken: 'refresh123',
    );
    await tokenStorage.saveUserData(
      id: 1,
      name: 'User',
      email: 'user@test.com',
    );

    await tokenStorage.clearTokens();

    expect(tokenStorage.hasAccessToken(), isFalse);
    expect(tokenStorage.getAccessToken(), isNull);
    expect(tokenStorage.getRefreshToken(), isNull);
    expect(tokenStorage.getUserData(), isNull);
  });
}
