import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/colorblind_condition.dart';

class ConditionApiService {
  final Dio dio;

  ConditionApiService({required this.dio});

  /// Updates user condition via PUT /api/v1/user/condition
  Future<void> updateCondition(ColorblindType condition) async {
    try {
      final backendCode = _toBackendCode(condition);
      final response = await dio.put(
        ApiEndpoints.userCondition,
        data: {'color_vision_type': backendCode},
      );

      final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (d) => d as Map<String, dynamic>,
      );

      if (!apiRes.success) {
        throw ServerException(
          apiRes.message.isNotEmpty ? apiRes.message : 'Gagal menyimpan kondisi',
        );
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Gets saved condition via GET /api/v1/user/profile
  Future<ColorblindType?> getSavedCondition() async {
    try {
      final response = await dio.get(ApiEndpoints.userProfile);

      final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (d) => d as Map<String, dynamic>,
      );

      if (apiRes.success && apiRes.data != null) {
        final conditionStr = apiRes.data!['color_vision_type'] as String?;
        if (conditionStr != null && conditionStr.isNotEmpty) {
          return _fromBackendCode(conditionStr);
        }
      }
      return null;
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  String _toBackendCode(ColorblindType type) {
    switch (type) {
      case ColorblindType.protanopia:
        return 'protanopia';
      case ColorblindType.deuteranopia:
        return 'deuteranopia';
      case ColorblindType.tritanopia:
        return 'tritanopia';
      case ColorblindType.monochromacy:
        return 'achromatopsia';
      case ColorblindType.normal:
        return 'normal';
    }
  }

  ColorblindType _fromBackendCode(String code) {
    final lower = code.toLowerCase().trim();
    if (lower.contains('deutan')) {
      return ColorblindType.deuteranopia;
    } else if (lower.contains('protan')) {
      return ColorblindType.protanopia;
    } else if (lower.contains('tritan')) {
      return ColorblindType.tritanopia;
    } else if (lower.contains('achromat') || lower.contains('monochrom')) {
      return ColorblindType.monochromacy;
    } else {
      return ColorblindType.normal;
    }
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
