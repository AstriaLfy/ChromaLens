import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TestOptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isSelected;

  const TestOptionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.brandPurple.withValues(alpha: 0.08)
              : Colors.white,
          side: BorderSide(
            color: isSelected ? AppColors.brandPurple : const Color(0xFFC8BFDC),
            width: isSelected ? 1.6 : 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.brandPurple : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
