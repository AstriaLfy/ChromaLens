import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../storage/token_storage.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/remote_auth_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/services/auth_api_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecases.dart';
import '../../features/auth/domain/usecases/google_sign_in_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';

// Colorblind Test
import '../../features/colorblind_test/data/datasources/colorblind_test_data_source.dart';
import '../../features/colorblind_test/data/datasources/remote_colorblind_test_data_source_impl.dart';
import '../../features/colorblind_test/data/repositories/colorblind_test_repository_impl.dart';
import '../../features/colorblind_test/data/services/colorblind_test_api_service.dart';
import '../../features/colorblind_test/domain/repositories/colorblind_test_repository.dart';
import '../../features/colorblind_test/domain/usecases/analyze_test_result_usecase.dart';
import '../../features/colorblind_test/domain/usecases/get_test_plates_usecase.dart';
import '../../features/colorblind_test/presentation/bloc/colorblind_test_bloc.dart';

// Select Condition
import '../../features/select_condition/data/datasources/condition_remote_data_source.dart';
import '../../features/select_condition/data/datasources/remote_condition_data_source_impl.dart';
import '../../features/select_condition/data/repositories/condition_repository_impl.dart';
import '../../features/select_condition/data/services/condition_api_service.dart';
import '../../features/select_condition/domain/repositories/condition_repository.dart';
import '../../features/select_condition/domain/usecases/save_condition_usecase.dart';
import '../../features/select_condition/presentation/bloc/select_condition_bloc.dart';

// Profile
import '../../features/profile/data/datasources/profile_data_source.dart';
import '../../features/profile/data/datasources/remote_profile_data_source_impl.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/data/services/profile_api_service.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;
final getIt = sl;

Future<void> initDependencies({SharedPreferences? preferences}) async {
  if (sl.isRegistered<TokenStorage>()) {
    return;
  }

  // Core - Storage & Network
  final sharedPreferences = preferences ?? await SharedPreferences.getInstance();

  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl()));
  sl.registerLazySingleton<DioClient>(() => DioClient(tokenStorage: sl()));

  // ==================== Services ====================
  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiService(
      dio: sl<DioClient>().dio,
      tokenStorage: sl<TokenStorage>(),
    ),
  );
  sl.registerLazySingleton<ProfileApiService>(
    () => ProfileApiService(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ConditionApiService>(
    () => ConditionApiService(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ColorblindTestApiService>(
    () => ColorblindTestApiService(dio: sl<DioClient>().dio),
  );

  // ==================== Data Sources ====================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => RemoteAuthDataSourceImpl(
      authApiService: sl(),
      tokenStorage: sl(),
    ),
  );
  sl.registerLazySingleton<ProfileDataSource>(
    () => RemoteProfileDataSourceImpl(
      apiService: sl(),
      localFallback: LocalProfileDataSourceImpl(tokenStorage: sl()),
    ),
  );
  sl.registerLazySingleton<ConditionRemoteDataSource>(
    () => RemoteConditionDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<ColorblindTestDataSource>(
    () => RemoteColorblindTestDataSourceImpl(apiService: sl()),
  );

  // ==================== Repositories ====================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<ConditionRepository>(
    () => ConditionRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ColorblindTestRepository>(
    () => ColorblindTestRepositoryImpl(dataSource: sl()),
  );

  // ==================== Use Cases ====================
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetEmailUseCase(sl()));
  sl.registerLazySingleton(() => VerifyResetCodeUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  // Profile
  sl.registerFactory(() => ProfileBloc(repository: sl()));

  // Select Condition
  sl.registerLazySingleton(() => SaveConditionUseCase(sl()));

  // Colorblind Test
  sl.registerLazySingleton(() => GetTestPlatesUseCase(sl()));
  sl.registerLazySingleton(() => AnalyzeTestResultUseCase(sl()));

  // ==================== Blocs ====================
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      googleSignInUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ForgotPasswordBloc(
      sendEmailUseCase: sl(),
      verifyCodeUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => SelectConditionBloc(
      saveConditionUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ColorblindTestBloc(
      getPlatesUseCase: sl(),
      analyzeResultUseCase: sl(),
    ),
  );
}
