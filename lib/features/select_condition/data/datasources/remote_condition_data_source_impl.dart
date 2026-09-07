import '../../domain/entities/colorblind_condition.dart';
import '../services/condition_api_service.dart';
import 'condition_remote_data_source.dart';

class RemoteConditionDataSourceImpl implements ConditionRemoteDataSource {
  final ConditionApiService apiService;
  final DummyConditionRemoteDataSourceImpl _localFallback = DummyConditionRemoteDataSourceImpl();

  RemoteConditionDataSourceImpl({required this.apiService});

  @override
  Future<void> saveCondition(ColorblindType condition) async {
    try {
      await apiService.updateCondition(condition);
    } catch (_) {
      await _localFallback.saveCondition(condition);
    }
  }

  @override
  Future<ColorblindType?> getSavedCondition() async {
    try {
      final cond = await apiService.getSavedCondition();
      if (cond != null) return cond;
    } catch (_) {
      // Fallback
    }
    return await _localFallback.getSavedCondition();
  }
}
