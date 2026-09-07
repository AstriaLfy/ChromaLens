import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/ishihara_plate.dart';
import '../repositories/colorblind_test_repository.dart';

class GetTestPlatesUseCase {
  final ColorblindTestRepository repository;

  GetTestPlatesUseCase(this.repository);

  Future<Either<Failure, List<IshiharaPlate>>> call() {
    return repository.getTestPlates();
  }
}
