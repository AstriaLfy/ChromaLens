import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/forgot_password/forgot_password_bloc.dart';
import '../bloc/forgot_password/forgot_password_event.dart';
import '../bloc/forgot_password/forgot_password_state.dart';
import '../widgets/auth_back_button.dart';
import '../widgets/custom_auth_text_field.dart';
import '../widgets/password_reset_success_dialog.dart';
import '../widgets/primary_action_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onResetSubmitted() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ForgotPasswordBloc>().add(
            ResetPasswordRequested(
              email: widget.email,
              code: widget.code,
              newPassword: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is ForgotPasswordSuccess) {
              PasswordResetSuccessDialog.show(
                context,
                onBackToLogin: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                },
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ForgotPasswordLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthBackButton(),
                    const SizedBox(height: 36),

                    // Centered Title
                    const Center(
                      child: Text(
                        'Buat Kata Sandi Baru',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // New Password Field
                    CustomAuthTextField(
                      label: 'Kata Sandi',
                      hintText: 'masukkan kata sandi baru',
                      controller: _passwordController,
                      isPassword: true,
                      validator: Validators.validatePassword,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 18),

                    // Confirm New Password Field
                    CustomAuthTextField(
                      label: 'Konfirmasi Kata Sandi',
                      hintText: 'konfirmasi kata sandi baru',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (val) => Validators.validateConfirmPassword(
                        val,
                        _passwordController.text,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 28),

                    // Button "Ganti Kata Sandi"
                    PrimaryActionButton(
                      text: 'Ganti Kata Sandi',
                      onPressed: _onResetSubmitted,
                      isEnabled: _passwordController.text.isNotEmpty &&
                          _confirmPasswordController.text.isNotEmpty,
                      isLoading: isLoading,
                      backgroundColor: AppColors.buttonPrimary,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
