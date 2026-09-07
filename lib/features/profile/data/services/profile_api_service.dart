import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileApiService {
  final Dio dio;

  ProfileApiService({required this.dio});

  /// Fetches the user profile from GET /api/v1/user/profile
  Future<UserProfileEntity> getProfile() async {
    try {
      final response = await dio.get(ApiEndpoints.userProfile);

      final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (d) => d as Map<String, dynamic>,
      );

      if (apiRes.success && apiRes.data != null) {
        return _mapToUserProfile(apiRes.data!);
      } else {
        throw ServerException(
          apiRes.message.isNotEmpty ? apiRes.message : 'Gagal mengambil profil',
        );
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Updates display name and/or avatar via PUT /api/v1/user/profile
  Future<UserProfileEntity> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (avatarUrl != null) payload['avatar_url'] = avatarUrl;

      final response = await dio.put(
        ApiEndpoints.userProfile,
        data: payload,
      );

      final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (d) => d as Map<String, dynamic>,
      );

      if (apiRes.success && apiRes.data != null) {
        return _mapToUserProfile(apiRes.data!);
      } else {
        throw ServerException(
          apiRes.message.isNotEmpty ? apiRes.message : 'Gagal memperbarui profil',
        );
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Updates settings via PATCH /api/v1/user/settings
  Future<UserProfileEntity> updateSettings({
    bool? notificationEnabled,
    String? language,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (notificationEnabled != null) {
        payload['notification_enabled'] = notificationEnabled;
      }
      if (language != null) {
        payload['language'] = language;
      }

      final response = await dio.patch(
        ApiEndpoints.userSettings,
        data: payload,
      );

      final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (d) => d as Map<String, dynamic>,
      );

      if (apiRes.success && apiRes.data != null) {
        return _mapToUserProfile(apiRes.data!);
      } else {
        throw ServerException(
          apiRes.message.isNotEmpty ? apiRes.message : 'Gagal memperbarui pengaturan',
        );
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  UserProfileEntity _mapToUserProfile(Map<String, dynamic> data) {
    String joinedStr = '19 Agt 1999';
    final rawDate = data['joined_at'] as String? ?? data['created_at'] as String?;
    if (rawDate != null) {
      final dt = DateTime.tryParse(rawDate);
      if (dt != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
        ];
        joinedStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      }
    }

    String conditionStr = data['color_vision_type'] as String? ?? 'Normal';
    if (conditionStr.isNotEmpty) {
      conditionStr = conditionStr[0].toUpperCase() + conditionStr.substring(1);
    }

    return UserProfileEntity(
      name: data['name'] as String? ?? 'ChromaLens User',
      email: data['email'] as String? ?? '',
      colorblindType: conditionStr,
      joinedDate: joinedStr,
      avatarUrl: data['avatar_url'] as String?,
      notificationEnabled: data['notification_enabled'] as bool? ?? true,
      language: (data['language'] as String? ?? 'id').toUpperCase() == 'ID'
          ? 'Indonesia'
          : 'English',
    );
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      final msg = data['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return e.message ?? 'Terjadi kesalahan pada server';
  }
}
