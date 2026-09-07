import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuthHeaderCurvedContainer extends StatelessWidget {
  final Widget child;

  const AuthHeaderCurvedContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    // Top purple header occupies approximately 16-20% of screen height
    final headerHeight = (screenHeight * 0.18).clamp(100.0, 160.0);

    return Scaffold(
      backgroundColor: AppColors.headerPurple,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // Top Purple Header Section
            SizedBox(
              height: headerHeight,
              width: double.infinity,
            ),
            // White Rounded Bottom Card Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(36),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(36),
                  ),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    child: child,
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
