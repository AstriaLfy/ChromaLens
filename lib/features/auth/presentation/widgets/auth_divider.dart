import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({
    super.key,
    this.text = 'Atau masuk dengan',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.dividerLine,
            thickness: 1.2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: AppTextStyles.dividerText,
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.dividerLine,
            thickness: 1.2,
          ),
        ),
      ],
    );
  }
}
