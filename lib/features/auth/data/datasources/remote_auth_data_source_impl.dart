import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import 'auth_remote_data_source.dart';
import 'dummy_auth_remote_data_source.dart';

class RemoteAuthDataSourceImpl implements AuthRemoteDataSource {
  final AuthApiService authApiService;
  final TokenStorage tokenStorage;
  final GoogleSignIn _googleSignIn;
  final DummyAuthRemoteDataSourceImpl _dummyFallback = DummyAuthRemoteDataSourceImpl();
  String? _lastResetToken;

  RemoteAuthDataSourceImpl({
    required this.authApiService,
    required this.tokenStorage,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ??
      GoogleSignIn(
        scopes: ['email', 'profile'],
        // Masukkan Server Web Client ID dari Google Cloud Console
        serverClientId: '152197514947-1lig0u6i1u8krut5h0o6kg6l3jqljbod.apps.googleusercontent.com',
      );

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await authApiService.login(
        email: email,
        password: password,
      );
      await tokenStorage.saveTokens(accessToken: user.token ?? '');
      await tokenStorage.saveUserData(name: user.name, email: user.email);
      return user;
    } on ServerException catch (e) {
      if (e.message.contains('Tidak dapat terhubung ke server') ||
          e.message.contains('timeout')) {
        final user = await _dummyFallback.login(email: email, password: password);
        await tokenStorage.saveTokens(accessToken: user.token ?? '');
        await tokenStorage.saveUserData(name: user.name, email: user.email);
        await tokenStorage.restoreUserSession(user.email);
        return user;
      }
      throw AuthException(e.message);
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    try {
      final name = email.split('@').first;
      final user = await authApiService.register(
        name: name.isNotEmpty ? name : 'Pengguna ChromaLens',
        email: email,
        password: password,
      );
      await tokenStorage.saveTokens(accessToken: user.token ?? '');
      await tokenStorage.saveUserData(name: user.name, email: user.email);
      return user;
    } on ServerException catch (e) {
      if (e.message.contains('Tidak dapat terhubung ke server') ||
          e.message.contains('timeout')) {
        final user = await _dummyFallback.register(email: email, password: password);
        await tokenStorage.saveTokens(accessToken: user.token ?? '');
        await tokenStorage.saveUserData(name: user.name, email: user.email);
        return user;
      }
      throw AuthException(e.message);
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      // 1. Pemicu Popup Google Sign-In SDK
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Proses masuk dengan Google dibatalkan.');
      }

      // 2. Ambil idToken dari Google Authentication
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const AuthException('Gagal mendapatkan ID Token dari Google.');
      }

      // 3. Kirim data asli ke API Golang via authApiService
      final user = await authApiService.googleLogin(
        idToken: idToken,
        email: googleUser.email,
        name: googleUser.displayName ?? googleUser.email.split('@').first,
        avatarUrl: googleUser.photoUrl ?? '',
      );

      // 4. Simpan JWT Token & User Data ke Storage
      await tokenStorage.saveTokens(accessToken: user.token ?? '');
      await tokenStorage.saveUserData(name: user.name, email: user.email);

      return user;
    } on ServerException catch (e) {
      if (e.message.contains('Tidak dapat terhubung ke server') ||
          e.message.contains('timeout')) {
        final user = await _dummyFallback.loginWithGoogle();
        await tokenStorage.saveTokens(accessToken: user.token ?? '');
        await tokenStorage.saveUserData(name: user.name, email: user.email);
        await tokenStorage.restoreUserSession(user.email);
        return user;
      }
      throw AuthException(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Gagal autentikasi Google: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await authApiService.logout();
    } finally {
      await tokenStorage.clearTokens();
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final userData = tokenStorage.getUserData();
    if (userData != null) {
      return UserModel(
        id: userData['id']?.toString() ?? '',
        email: userData['email'] as String? ?? '',
        name: userData['name'] as String? ?? 'ChromaLens User',
        token: token,
      );
    }

    return null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await authApiService.sendPasswordResetEmail(email);
    } on ServerException catch (e) {
      if (e.message.contains('Tidak dapat terhubung ke server') ||
          e.message.contains('timeout')) {
        return await _dummyFallback.sendPasswordResetEmail(email);
      }
      throw AuthException(e.message);
    }
  }

  @override
  Future<bool> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      _lastResetToken = await authApiService.verifyResetCode(email, code);
      return true;
    } on ServerException catch (e) {
      if (e.message.contains('Tidak dapat terhubung ke server') ||
          e.message.contains('timeout')) {
        return await _dummyFallback.verifyResetCode(email: email, code: code);
      }
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await authApiService.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
        resetToken: _lastResetToken,
      );
    } on ServerException catch (e) {
      if (e.message.contains('Tidak dapat terhubung ke server') ||
          e.message.contains('timeout')) {
        return await _dummyFallback.resetPassword(
          email: email,
          code: code,
          newPassword: newPassword,
        );
      }
      throw AuthException(e.message);
    }
  }
}