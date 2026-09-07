import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  final String? message;
  const ForgotPasswordLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordEmailSent extends ForgotPasswordState {
  final String email;
  final String message;

  const ForgotPasswordEmailSent({
    required this.email,
    this.message = 'Kode verifikasi telah dikirimkan ke email Anda.',
  });

  @override
  List<Object?> get props => [email, message];
}

class ForgotPasswordCodeVerified extends ForgotPasswordState {
  final String email;
  final String code;

  const ForgotPasswordCodeVerified({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [email, code];
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;

  const ForgotPasswordSuccess({
    this.message = 'Kata sandi anda berhasil diubah.',
  });

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;

  const ForgotPasswordError(this.message);

  @override
  List<Object?> get props => [message];
}
