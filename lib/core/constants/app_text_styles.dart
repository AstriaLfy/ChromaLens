import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Brand Logo
  static const TextStyle logo = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
    color: AppColors.logoPurple,
  );

  static const TextStyle tagline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.subtitlePurple,
  );

  // Form Field Labels
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Form Field Input & Hint
  static const TextStyle inputText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );

  // Links & Prompts
  static const TextStyle forgotPassword = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle dividerText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  // Buttons
  static const TextStyle primaryButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  static const TextStyle googleButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Footers
  static const TextStyle footerText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );

  static const TextStyle footerLink = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.linkPurple,
  );
}
