import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer_prompt.dart';
import '../widgets/auth_header_curved_container.dart';
import '../widgets/chromalens_logo.dart';
import '../widgets/custom_auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/offline_mode_button.dart';
import '../widgets/primary_action_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isGoogleAction = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginSubmitted() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isGoogleAction = false);
      context.read<AuthBloc>().add(
            LoginSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _onGoogleSignIn() {
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleAction = true);
    context.read<AuthBloc>().add(const GoogleSignInSubmitted());
  }

  void _onForgotPassword() {
    Navigator.pushNamed(context, '/forgot_password');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );

          final tokenStorage = sl<TokenStorage>();
          final email = state.user.email;
          final hasCondition = tokenStorage.hasCompletedCondition(email: email) ||
              (state.user.colorVisionType != null && state.user.colorVisionType!.isNotEmpty);

          if (hasCondition) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushReplacementNamed(context, '/select_condition');
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final isGoogleLoading = isLoading && _isGoogleAction;
        final isNormalLoading = isLoading && !_isGoogleAction;

        return AuthHeaderCurvedContainer(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                // ChromaLens Logo & Tagline
                const Center(
                  child: ChromaLensLogo(
                    fontSize: 26,
                    showTagline: true,
                  ),
                ),
                const SizedBox(height: 32),

                // Email Input
                CustomAuthTextField(
                  label: 'Email',
                  hintText: 'cth: user21@gmail.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 18),

                // Password Input
                CustomAuthTextField(
                  label: 'Kata Sandi',
                  hintText: 'masukkan kata sandi',
                  controller: _passwordController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.validatePassword,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),

                // Lupa Kata Sandi
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: _onForgotPassword,
                    child: const Text(
                      'Lupa kata sandi?',
                      style: AppTextStyles.forgotPassword,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Divider "Atau masuk dengan"
                const AuthDivider(text: 'Atau masuk dengan'),
                const SizedBox(height: 20),

                // Google Sign In Button
                GoogleSignInButton(
                  onPressed: _onGoogleSignIn,
                  isLoading: isGoogleLoading,
                ),
                const SizedBox(height: 16),

                // Offline Mode Button
                OfflineModeButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/home',
                      arguments: {'offline': true},
                    );
                  },
                ),
                const SizedBox(height: 48),

                // Action Button "Selanjutnya"
                PrimaryActionButton(
                  text: 'Selanjutnya',
                  onPressed: _onLoginSubmitted,
                  isEnabled: _emailController.text.isNotEmpty &&
                      _passwordController.text.isNotEmpty,
                  isLoading: isNormalLoading,
                ),
                const SizedBox(height: 20),

                // Footer Prompt
                AuthFooterPrompt(
                  question: 'Belum punya akun?',
                  actionText: 'Daftar',
                  onActionTap: () {
                    context.read<AuthBloc>().add(const AuthResetState());
                    Navigator.pushNamed(context, '/register');
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
