import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Melakukan login dengan email dan kata sandi
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Melakukan registrasi akun baru
  Future<UserModel> register({
    required String email,
    required String password,
  });

  /// Melakukan login / pendaftaran via Google
  Future<UserModel> loginWithGoogle();

  /// Melakukan logout
  Future<void> logout();

  /// Mendapatkan user yang sedang aktif
  Future<UserModel?> getCurrentUser();

  /// Mengirim kode reset password ke email
  Future<void> sendPasswordResetEmail(String email);

  /// Memverifikasi kode OTP 4 digit
  Future<bool> verifyResetCode({
    required String email,
    required String code,
  });

  /// Mengganti kata sandi baru dengan kode reset
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}
