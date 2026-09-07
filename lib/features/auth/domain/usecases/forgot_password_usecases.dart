import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) {
    return repository.sendPasswordResetEmail(email);
  }
}

class VerifyResetCodeUseCase {
  final AuthRepository repository;

  VerifyResetCodeUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String email,
    required String code,
  }) {
    return repository.verifyResetCode(email: email, code: code);
  }
}

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return repository.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }
}
