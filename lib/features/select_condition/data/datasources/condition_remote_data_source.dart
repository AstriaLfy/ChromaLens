import '../../domain/entities/colorblind_condition.dart';

abstract class ConditionRemoteDataSource {
  Future<void> saveCondition(ColorblindType condition);
  Future<ColorblindType?> getSavedCondition();
}

class DummyConditionRemoteDataSourceImpl implements ConditionRemoteDataSource {
  ColorblindType? _savedCondition;

  @override
  Future<void> saveCondition(ColorblindType condition) async {
    // Simulasi delay network
    await Future.delayed(const Duration(milliseconds: 800));
    _savedCondition = condition;
  }

  @override
  Future<ColorblindType?> getSavedCondition() async {
    return _savedCondition;
  }
}
