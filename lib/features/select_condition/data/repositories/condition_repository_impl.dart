import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/colorblind_condition.dart';
import '../../domain/repositories/condition_repository.dart';
import '../datasources/condition_remote_data_source.dart';

class ConditionRepositoryImpl implements ConditionRepository {
  final ConditionRemoteDataSource remoteDataSource;

  ConditionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> saveCondition(ColorblindType condition) async {
    try {
      await remoteDataSource.saveCondition(condition);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ColorblindType?>> getSavedCondition() async {
    try {
      final condition = await remoteDataSource.getSavedCondition();
      return Right(condition);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
