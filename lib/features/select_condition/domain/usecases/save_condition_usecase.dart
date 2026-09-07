import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/colorblind_condition.dart';
import '../repositories/condition_repository.dart';

class SaveConditionUseCase {
  final ConditionRepository repository;

  SaveConditionUseCase(this.repository);

  Future<Either<Failure, void>> call(ColorblindType condition) {
    return repository.saveCondition(condition);
  }
}
