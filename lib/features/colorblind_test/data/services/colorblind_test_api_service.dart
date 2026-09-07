import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/ishihara_plate.dart';
import '../../domain/entities/test_result_entity.dart';

class ColorblindTestApiService {
  final Dio dio;

  ColorblindTestApiService({required this.dio});

  /// Fetches the 12 Ishihara plates from GET /api/v1/tests/ishihara/plates
  Future<List<IshiharaPlate>> getPlates() async {
    try {
      final response = await dio.get(ApiEndpoints.ishiharaPlates);

      final apiRes = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (d) => d as List<dynamic>,
      );

      if (apiRes.success && apiRes.data != null) {
        return apiRes.data!.map((item) {
          final plate = item as Map<String, dynamic>;
          final id = plate['id'] as int? ?? 0;
          final plateNumber = plate['plate_number'] as int? ?? id;
          final rawOptions = (plate['options'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];

          // Translate options to Indonesian friendly terms
          final options = rawOptions.map((opt) {
            final lower = opt.toLowerCase();
            if (lower == 'nothing') return 'Tidak Melihat Angka';
            if (lower == 'others') return 'Melihat Angka Lain';
            return opt;
          }).toList();

          // Identify normal number
          final numberText = rawOptions.firstWhere(
            (opt) => opt != 'nothing' && opt != 'others',
            orElse: () => plateNumber.toString(),
          );

          return IshiharaPlate(
            id: id,
            numberText: numberText,
            options: options,
            correctAnswer: numberText,
            description: plate['description'] as String? ?? '',
            imageUrl: plate['image_url'] as String?,
          );
        }).toList();
      } else {
        throw ServerException(
          apiRes.message.isNotEmpty ? apiRes.message : 'Gagal memuat lempeng tes',
        );
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Submits test answers to POST /api/v1/tests/ishihara/submit
  Future<TestResultEntity> submitAnswers(Map<int, String> answers) async {
    try {
      final answersList = answers.entries.map((entry) {
        String answerValue = entry.value;
        if (answerValue == 'Tidak Melihat Angka') {
          answerValue = 'nothing';
        } else if (answerValue == 'Melihat Angka Lain') {
          answerValue = 'others';
        }

        return {
          'plate_id': entry.key,
          'selected_answer': answerValue,
          'answer': answerValue,
        };
      }).toList();

      final response = await dio.post(
        ApiEndpoints.submitAnswers,
        data: {'answers': answersList},
      );

      final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (d) => d as Map<String, dynamic>,
      );

      if (apiRes.success && apiRes.data != null) {
        return _mapToTestResult(apiRes.data!);
      } else {
        throw ServerException(
          apiRes.message.isNotEmpty ? apiRes.message : 'Gagal mengevaluasi hasil tes',
        );
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Retrieves the latest test result from GET /api/v1/tests/latest
  Future<TestResultEntity?> getLatestTestResult() async {
    try {
      final response = await dio.get(ApiEndpoints.latestTestResult);

      final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (d) => d as Map<String, dynamic>,
      );

      if (apiRes.success && apiRes.data != null) {
        return _mapToTestResult(apiRes.data!);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Retrieves historical tests from GET /api/v1/tests/history
  Future<List<TestResultEntity>> getTestHistory() async {
    try {
      final response = await dio.get(ApiEndpoints.testHistory);

      final apiRes = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (d) => d as List<dynamic>,
      );

      if (apiRes.success && apiRes.data != null) {
        return apiRes.data!
            .map((item) => _mapToTestResult(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  TestResultEntity _mapToTestResult(Map<String, dynamic> data) {
    return TestResultEntity(
      diagnosis: data['diagnosis'] as String? ?? 'Penglihatan Normal',
      description: data['description'] as String? ?? '',
      affectedColors: data['affected_colors'] as String? ?? 'Tidak Ada',
      category: data['category'] as String? ?? 'Normal',
      testDate: DateTime.tryParse(data['test_date'] as String? ?? '') ?? DateTime.now(),
      correctCount: data['correct_count'] as int? ?? 0,
      totalQuestions: data['total_questions'] as int? ?? 12,
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
