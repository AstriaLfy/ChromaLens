import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';

class AuthFooterPrompt extends StatelessWidget {
  final String question;
  final String actionText;
  final VoidCallback onActionTap;

  const AuthFooterPrompt({
    super.key,
    required this.question,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            question,
            style: AppTextStyles.footerText,
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText,
              style: AppTextStyles.footerLink,
            ),
          ),
        ],
      ),
    );
  }
}
