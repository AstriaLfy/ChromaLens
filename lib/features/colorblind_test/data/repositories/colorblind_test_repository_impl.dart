import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/ishihara_plate.dart';
import '../../domain/entities/test_result_entity.dart';
import '../../domain/repositories/colorblind_test_repository.dart';
import '../datasources/colorblind_test_data_source.dart';

class ColorblindTestRepositoryImpl implements ColorblindTestRepository {
  final ColorblindTestDataSource dataSource;

  ColorblindTestRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<IshiharaPlate>>> getTestPlates() async {
    try {
      final plates = await dataSource.getPlates();
      return Right(plates);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TestResultEntity>> analyzeResults(Map<int, String> answers) async {
    try {
      final result = await dataSource.analyzeAnswers(answers);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
