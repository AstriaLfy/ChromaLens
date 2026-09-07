import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/test_result_entity.dart';
import '../repositories/colorblind_test_repository.dart';

class AnalyzeTestResultUseCase {
  final ColorblindTestRepository repository;

  AnalyzeTestResultUseCase(this.repository);

  Future<Either<Failure, TestResultEntity>> call(Map<int, String> answers) {
    return repository.analyzeResults(answers);
  }
}
