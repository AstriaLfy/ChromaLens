import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/colorblind_condition.dart';

abstract class ConditionRepository {
  Future<Either<Failure, void>> saveCondition(ColorblindType condition);
  Future<Either<Failure, ColorblindType?>> getSavedCondition();
}
