import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/forgot_password_usecases.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final SendPasswordResetEmailUseCase sendEmailUseCase;
  final VerifyResetCodeUseCase verifyCodeUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  ForgotPasswordBloc({
    required this.sendEmailUseCase,
    required this.verifyCodeUseCase,
    required this.resetPasswordUseCase,
  }) : super(const ForgotPasswordInitial()) {
    on<SendResetEmailRequested>(_onSendResetEmailRequested);
    on<VerifyCodeRequested>(_onVerifyCodeRequested);
    on<ResendCodeRequested>(_onResendCodeRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<ForgotPasswordResetState>(_onForgotPasswordResetState);
  }

  Future<void> _onSendResetEmailRequested(
    SendResetEmailRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading(message: 'Mengirimkan kode verifikasi...'));

    final result = await sendEmailUseCase(event.email);

    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message)),
      (_) => emit(ForgotPasswordEmailSent(email: event.email)),
    );
  }

  Future<void> _onVerifyCodeRequested(
    VerifyCodeRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading(message: 'Memverifikasi kode...'));

    final result = await verifyCodeUseCase(
      email: event.email,
      code: event.code,
    );

    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message)),
      (_) => emit(ForgotPasswordCodeVerified(
        email: event.email,
        code: event.code,
      )),
    );
  }

  Future<void> _onResendCodeRequested(
    ResendCodeRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final result = await sendEmailUseCase(event.email);

    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message)),
      (_) => emit(ForgotPasswordEmailSent(
        email: event.email,
        message: 'Kode verifikasi baru telah dikirimkan ke email Anda.',
      )),
    );
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (event.newPassword != event.confirmPassword) {
      emit(const ForgotPasswordError('Konfirmasi kata sandi tidak cocok.'));
      return;
    }

    emit(const ForgotPasswordLoading(message: 'Memperbarui kata sandi...'));

    final result = await resetPasswordUseCase(
      email: event.email,
      code: event.code,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }

  void _onForgotPasswordResetState(
    ForgotPasswordResetState event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(const ForgotPasswordInitial());
  }
}
