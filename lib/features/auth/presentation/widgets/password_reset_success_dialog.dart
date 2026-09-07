import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PasswordResetSuccessDialog extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const PasswordResetSuccessDialog({
    super.key,
    required this.onBackToLogin,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onBackToLogin}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PasswordResetSuccessDialog(onBackToLogin: onBackToLogin),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular badge with checkmark icon
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: AppColors.buttonPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Kata sandi anda\nberhasil diubah',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.buttonPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            const Text(
              'Kembali ke halaman login dan masuk\nmenggunakan kata sandi yang baru',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onBackToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Kembali ke halaman login',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
