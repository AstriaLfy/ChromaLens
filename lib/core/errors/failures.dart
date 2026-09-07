import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Terjadi kesalahan pada server.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Email atau kata sandi tidak valid.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Koneksi jaringan bermasalah.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
