import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/ishihara_plate.dart';
import '../entities/test_result_entity.dart';

abstract class ColorblindTestRepository {
  Future<Either<Failure, List<IshiharaPlate>>> getTestPlates();

  Future<Either<Failure, TestResultEntity>> analyzeResults(Map<int, String> answers);
}
