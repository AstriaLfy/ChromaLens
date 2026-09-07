import 'package:flutter_test/flutter_test.dart';

import 'package:chroma_lens/features/auth/data/datasources/dummy_auth_remote_data_source.dart';
import 'package:chroma_lens/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chroma_lens/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:chroma_lens/features/auth/domain/usecases/login_usecase.dart';
import 'package:chroma_lens/features/auth/domain/usecases/register_usecase.dart';
import 'package:chroma_lens/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chroma_lens/features/auth/presentation/bloc/auth_event.dart';
import 'package:chroma_lens/features/auth/presentation/bloc/auth_state.dart';

void main() {
  late AuthBloc authBloc;
  late DummyAuthRemoteDataSourceImpl dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = DummyAuthRemoteDataSourceImpl();
    repository = AuthRepositoryImpl(remoteDataSource: dataSource);
    authBloc = AuthBloc(
      loginUseCase: LoginUseCase(repository),
      registerUseCase: RegisterUseCase(repository),
      googleSignInUseCase: GoogleSignInUseCase(repository),
    );
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, const AuthInitial());
  });

  test('LoginSubmitted emits [AuthLoading, AuthAuthenticated] on success', () async {
    final expected = [
      const AuthLoading(message: 'Sedang masuk...'),
      isA<AuthAuthenticated>(),
    ];

    expectLater(authBloc.stream, emitsInOrder(expected));

    authBloc.add(const LoginSubmitted(
      email: 'user21@gmail.com',
      password: 'password123',
    ));
  });

  test('LoginSubmitted emits [AuthLoading, AuthError] on failure', () async {
    final expected = [
      const AuthLoading(message: 'Sedang masuk...'),
      isA<AuthError>(),
    ];

    expectLater(authBloc.stream, emitsInOrder(expected));

    authBloc.add(const LoginSubmitted(
      email: 'error_user@gmail.com',
      password: 'password123',
    ));
  });

  test('RegisterSubmitted emits [AuthLoading, AuthAuthenticated] on success', () async {
    final expected = [
      const AuthLoading(message: 'Sedang membuat akun...'),
      isA<AuthAuthenticated>(),
    ];

    expectLater(authBloc.stream, emitsInOrder(expected));

    authBloc.add(const RegisterSubmitted(
      email: 'newuser@gmail.com',
      password: 'password123',
      confirmPassword: 'password123',
    ));
  });

  test('GoogleSignInSubmitted emits [AuthLoading, AuthAuthenticated] on success', () async {
    final expected = [
      const AuthLoading(message: 'Menghubungkan ke Google...'),
      isA<AuthAuthenticated>(),
    ];

    expectLater(authBloc.stream, emitsInOrder(expected));

    authBloc.add(const GoogleSignInSubmitted());
  });
}
