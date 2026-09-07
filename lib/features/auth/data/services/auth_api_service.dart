import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthApiService {
  final Dio dio;
  final TokenStorage tokenStorage;

  AuthApiService({
    required this.dio,
    required this.tokenStorage,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (d) => d as Map<String, dynamic>,
      );

      if (apiRes.success && apiRes.data != null) {
        final data = apiRes.data!;
        final accessToken = data['access_token'] as String? ?? data['token'] as String? ?? '';
        final refreshToken = data['refresh_token'] as String?;
        final userData = data['user'] as Map<String, dynamic>? ?? {};

        await tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        final colorVisionType = userData['color_vision_type'] as String? ??
            userData['colorblind_type'] as String?;

        final user = UserModel(
          id: userData['id']?.toString() ?? '',
          email: userData['email'] as String? ?? email,
          name: userData['name'] as String? ?? 'ChromaLens User',
          token: accessToken,
          colorVisionType: colorVisionType,
        );

        await tokenStorage.saveUserData(
          id: userData['id'] is int ? userData['id'] as int : null,
          name: user.name,
          email: user.email,
        );

        if (colorVisionType != null && colorVisionType.isNotEmpty) {
          await tokenStorage.saveCondition(
            type: colorVisionType,
            description: '',
            email: user.email,
          );
        } else {
          await tokenStorage.restoreUserSession(user.email);
        }

        return user;
      } else {
        throw ServerException(apiRes.message.isNotEmpty ? apiRes.message : 'Login gagal');
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (d) => d as Map<String, dynamic>,
      );

      if (apiRes.success && apiRes.data != null) {
        final data = apiRes.data!;
        final accessToken = data['access_token'] as String? ?? data['token'] as String? ?? '';
        final refreshToken = data['refresh_token'] as String?;
        final userData = data['user'] as Map<String, dynamic>? ?? {};

        if (accessToken.isNotEmpty) {
          await tokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }

        final user = UserModel(
          id: userData['id']?.toString() ?? '',
          email: userData['email'] as String? ?? email,
          name: userData['name'] as String? ?? name,
          token: accessToken,
        );

        return user;
      } else {
        throw ServerException(apiRes.message.isNotEmpty ? apiRes.message : 'Registrasi gagal');
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<UserModel> googleLogin({
    required String idToken,
    required String email,
    required String name,
    String? avatarUrl,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.googleLogin,
        data: {
          'id_token': idToken,
          'email': email,
          'name': name,
          'avatar_url': ?avatarUrl,
        },
      );

      final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (d) => d as Map<String, dynamic>,
      );

      if (apiRes.success && apiRes.data != null) {
        final data = apiRes.data!;
        final accessToken = data['access_token'] as String? ?? data['token'] as String? ?? '';
        final refreshToken = data['refresh_token'] as String?;
        final userData = data['user'] as Map<String, dynamic>? ?? {};

        await tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        final colorVisionType = userData['color_vision_type'] as String? ??
            userData['colorblind_type'] as String?;

        final user = UserModel(
          id: userData['id']?.toString() ?? '',
          email: userData['email'] as String? ?? email,
          name: userData['name'] as String? ?? name,
          token: accessToken,
          colorVisionType: colorVisionType,
        );

        await tokenStorage.saveUserData(
          id: userData['id'] is int ? userData['id'] as int : null,
          name: user.name,
          email: user.email,
        );

        if (colorVisionType != null && colorVisionType.isNotEmpty) {
          await tokenStorage.saveCondition(
            type: colorVisionType,
            description: '',
            email: user.email,
          );
        } else {
          await tokenStorage.restoreUserSession(user.email);
        }

        return user;
      } else {
        throw ServerException(apiRes.message.isNotEmpty ? apiRes.message : 'Google login gagal');
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final response = await dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      final apiRes = ApiResponse<dynamic>.fromJson(response.data, null);
      if (!apiRes.success) {
        throw ServerException(apiRes.message.isNotEmpty ? apiRes.message : 'Gagal mengirim email reset password');
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<String?> verifyResetCode(String email, String code) async {
    try {
      final response = await dio.post(
        ApiEndpoints.verifyResetCode,
        data: {
          'email': email,
          'code': code,
        },
      );

      final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (d) => d as Map<String, dynamic>,
      );

      if (apiRes.success) {
        final data = apiRes.data;
        return data?['reset_token'] as String?;
      } else {
        throw ServerException(apiRes.message.isNotEmpty ? apiRes.message : 'Kode verifikasi tidak valid');
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    String? resetToken,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
          'reset_token': ?resetToken,
        },
      );

      final apiRes = ApiResponse<dynamic>.fromJson(response.data, null);
      if (!apiRes.success) {
        throw ServerException(apiRes.message.isNotEmpty ? apiRes.message : 'Gagal mengubah kata sandi');
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<void> logout() async {
    try {
      await dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore network errors during logout
    } finally {
      await tokenStorage.clearTokens();
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      final msg = data['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi ke server timeout. Silakan periksa jaringan Anda.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server. Pastikan backend aktif pada ${ApiEndpoints.baseUrl}';
    }
    return e.message ?? 'Terjadi kesalahan pada server';
  }
}
