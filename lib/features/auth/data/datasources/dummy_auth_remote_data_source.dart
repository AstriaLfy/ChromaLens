import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class DummyAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  UserModel? _currentUser;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (email.toLowerCase().contains('error') || email.toLowerCase().contains('fail')) {
      throw const AuthException('Email atau kata sandi tidak sesuai. Silakan coba lagi.');
    }

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: email.split('@').first,
      token: 'dummy_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    _currentUser = user;
    return user;
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (email.toLowerCase().contains('error') || email.toLowerCase().contains('exist')) {
      throw const AuthException('Email ini sudah terdaftar. Silakan gunakan email lain.');
    }

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: email.split('@').first,
      token: 'dummy_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    _currentUser = user;
    return user;
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    const email = 'chroma.user@gmail.com';
    final username = email.split('@').first;

    final user = UserModel(
      id: 'google_usr_998877',
      email: email,
      name: username,
      token: 'dummy_google_oauth_token',
    );

    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (email.toLowerCase().contains('notfound') || email.toLowerCase().contains('error')) {
      throw const AuthException('Email tidak ditemukan. Pastikan email terdaftar.');
    }
  }

  @override
  Future<bool> verifyResetCode({
    required String email,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (code == '0000') {
      throw const AuthException('Kode verifikasi salah atau sudah kedaluwarsa.');
    }

    return true;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (newPassword.length < 6) {
      throw const AuthException('Kata sandi baru minimal 6 karakter.');
    }
  }
}
