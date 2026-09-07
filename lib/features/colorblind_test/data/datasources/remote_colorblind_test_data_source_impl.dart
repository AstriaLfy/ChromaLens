import 'package:flutter/foundation.dart';
import '../../domain/entities/ishihara_plate.dart';
import '../../domain/entities/test_result_entity.dart';
import '../services/colorblind_test_api_service.dart';
import 'colorblind_test_data_source.dart';

class RemoteColorblindTestDataSourceImpl implements ColorblindTestDataSource {
  final ColorblindTestApiService apiService;
  final LocalColorblindTestDataSourceImpl _localFallback = LocalColorblindTestDataSourceImpl();

  RemoteColorblindTestDataSourceImpl({required this.apiService});

  @override
  Future<List<IshiharaPlate>> getPlates() async {
    try {
      final plates = await apiService.getPlates();
      if (plates.isNotEmpty) {
        debugPrint('[ColorblindTest] Berhasil memuat ${plates.length} plates dari Backend API');
        return plates;
      }
    } catch (e) {
      debugPrint('[ColorblindTest] Gagal memuat plates dari Backend API: $e. Menggunakan fallback lokal.');
    }
    return await _localFallback.getPlates();
  }

  @override
  Future<TestResultEntity> analyzeAnswers(Map<int, String> answers) async {
    try {
      final result = await apiService.submitAnswers(answers);
      debugPrint('[ColorblindTest] Berhasil submit & evaluasi tes di Backend API: ${result.diagnosis}');
      return result;
    } catch (e) {
      debugPrint('[ColorblindTest] Gagal submit ke Backend API: $e. Menggunakan evaluasi lokal fallback.');
      return await _localFallback.analyzeAnswers(answers);
    }
  }
}
