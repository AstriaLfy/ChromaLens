import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/config/router.dart';
import 'core/di/injection_container.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'features/colorblind_test/presentation/bloc/colorblind_test_bloc.dart';
import 'features/select_condition/presentation/bloc/select_condition_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  final tokenStorage = sl<TokenStorage>();
  final isLoggedIn = tokenStorage.hasAccessToken();
  final hasCondition = tokenStorage.hasCompletedCondition();
  final initialRoute = isLoggedIn
      ? (hasCondition ? AppRoutes.home : AppRoutes.selectCondition)
      : AppRoutes.login;
  runApp(ChromaLensApp(
    initialRoute: initialRoute,
  ));
}

class ChromaLensApp extends StatelessWidget {
  final String initialRoute;

  const ChromaLensApp({
    super.key,
    this.initialRoute = AppRoutes.login,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<ForgotPasswordBloc>(
          create: (_) => sl<ForgotPasswordBloc>(),
        ),
        BlocProvider<SelectConditionBloc>(
          create: (_) => sl<SelectConditionBloc>(),
        ),
        BlocProvider<ColorblindTestBloc>(
          create: (_) => sl<ColorblindTestBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'ChromaLens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: initialRoute,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
