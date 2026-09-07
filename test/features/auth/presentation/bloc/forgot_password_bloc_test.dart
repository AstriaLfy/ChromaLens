import 'package:flutter_test/flutter_test.dart';

import 'package:chroma_lens/features/auth/data/datasources/dummy_auth_remote_data_source.dart';
import 'package:chroma_lens/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chroma_lens/features/auth/domain/usecases/forgot_password_usecases.dart';
import 'package:chroma_lens/features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:chroma_lens/features/auth/presentation/bloc/forgot_password/forgot_password_event.dart';
import 'package:chroma_lens/features/auth/presentation/bloc/forgot_password/forgot_password_state.dart';

void main() {
  late ForgotPasswordBloc bloc;
  late DummyAuthRemoteDataSourceImpl dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = DummyAuthRemoteDataSourceImpl();
    repository = AuthRepositoryImpl(remoteDataSource: dataSource);
    bloc = ForgotPasswordBloc(
      sendEmailUseCase: SendPasswordResetEmailUseCase(repository),
      verifyCodeUseCase: VerifyResetCodeUseCase(repository),
      resetPasswordUseCase: ResetPasswordUseCase(repository),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be ForgotPasswordInitial', () {
    expect(bloc.state, const ForgotPasswordInitial());
  });

  test('SendResetEmailRequested emits [Loading, EmailSent] on success', () async {
    final expected = [
      const ForgotPasswordLoading(message: 'Mengirimkan kode verifikasi...'),
      const ForgotPasswordEmailSent(email: 'user2@gmail.com'),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    bloc.add(const SendResetEmailRequested('user2@gmail.com'));
  });

  test('VerifyCodeRequested emits [Loading, CodeVerified] on valid code', () async {
    final expected = [
      const ForgotPasswordLoading(message: 'Memverifikasi kode...'),
      const ForgotPasswordCodeVerified(
        email: 'user2@gmail.com',
        code: '1234',
      ),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    bloc.add(const VerifyCodeRequested(
      email: 'user2@gmail.com',
      code: '1234',
    ));
  });

  test('ResetPasswordRequested emits [Loading, Success] when passwords match', () async {
    final expected = [
      const ForgotPasswordLoading(message: 'Memperbarui kata sandi...'),
      const ForgotPasswordSuccess(),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    bloc.add(const ResetPasswordRequested(
      email: 'user2@gmail.com',
      code: '1234',
      newPassword: 'newpassword123',
      confirmPassword: 'newpassword123',
    ));
  });

  test('ResetPasswordRequested emits Error when passwords mismatch', () async {
    final expected = [
      const ForgotPasswordError('Konfirmasi kata sandi tidak cocok.'),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    bloc.add(const ResetPasswordRequested(
      email: 'user2@gmail.com',
      code: '1234',
      newPassword: 'newpassword123',
      confirmPassword: 'mismatched123',
    ));
  });
}
