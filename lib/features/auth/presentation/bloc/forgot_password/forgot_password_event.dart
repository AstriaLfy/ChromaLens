import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class SendResetEmailRequested extends ForgotPasswordEvent {
  final String email;

  const SendResetEmailRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyCodeRequested extends ForgotPasswordEvent {
  final String email;
  final String code;

  const VerifyCodeRequested({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [email, code];
}

class ResendCodeRequested extends ForgotPasswordEvent {
  final String email;

  const ResendCodeRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class ResetPasswordRequested extends ForgotPasswordEvent {
  final String email;
  final String code;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequested({
    required this.email,
    required this.code,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword, confirmPassword];
}

class ForgotPasswordResetState extends ForgotPasswordEvent {
  const ForgotPasswordResetState();
}
