import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/forgot_password/forgot_password_bloc.dart';
import '../bloc/forgot_password/forgot_password_event.dart';
import '../bloc/forgot_password/forgot_password_state.dart';
import '../widgets/auth_back_button.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/primary_action_button.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  String _otpCode = '';
  int _countdownSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _countdownSeconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onVerify() {
    if (_otpCode.length == 4) {
      context.read<ForgotPasswordBloc>().add(
            VerifyCodeRequested(
              email: widget.email,
              code: _otpCode,
            ),
          );
    }
  }

  void _onResend() {
    if (_countdownSeconds == 0) {
      context.read<ForgotPasswordBloc>().add(
            ResendCodeRequested(widget.email),
          );
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerText = '0:${_countdownSeconds.toString().padLeft(2, '0')}';

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
            } else if (state is ForgotPasswordCodeVerified) {
              Navigator.pushNamed(
                context,
                '/reset_password',
                arguments: {
                  'email': state.email,
                  'code': state.code,
                },
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ForgotPasswordLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuthBackButton(),
                  const SizedBox(height: 36),

                  // Title (Centered)
                  const Center(
                    child: Text(
                      'Verifikasi Email',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle with Email
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                        children: [
                          const TextSpan(text: 'Kode telah dikirimkan ke '),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              color: AppColors.brandPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 4-digit OTP Box
                  OtpInputField(
                    length: 4,
                    onChanged: (code) => setState(() => _otpCode = code),
                    onCompleted: (code) {
                      setState(() => _otpCode = code);
                      _onVerify();
                    },
                  ),
                  const SizedBox(height: 24),

                  // Button "Konfirmasi Kode"
                  PrimaryActionButton(
                    text: 'Konfirmasi Kode',
                    onPressed: _onVerify,
                    isEnabled: _otpCode.length == 4,
                    isLoading: isLoading,
                    backgroundColor: AppColors.buttonPrimary,
                  ),
                  const SizedBox(height: 20),

                  // Resend Code with Countdown
                  Center(
                    child: GestureDetector(
                      onTap: _countdownSeconds == 0 ? _onResend : null,
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                          children: [
                            TextSpan(
                              text: '$timerText ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'Kirim ulang kode verifikasi',
                              style: TextStyle(
                                color: _countdownSeconds == 0
                                    ? AppColors.brandPurple
                                    : AppColors.textGrey,
                                fontWeight: _countdownSeconds == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
