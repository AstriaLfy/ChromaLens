import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ChromaLensLogo extends StatelessWidget {
  final double fontSize;
  final bool showTagline;

  const ChromaLensLogo({
    super.key,
    this.fontSize = 28,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    final lensSize = fontSize * 0.85;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'CHR',
              style: AppTextStyles.logo.copyWith(fontSize: fontSize),
            ),
            const SizedBox(width: 1),
            SizedBox(
              width: lensSize,
              height: lensSize,
              child: CustomPaint(
                painter: _LensIconPainter(color: AppColors.logoPurple),
              ),
            ),
            const SizedBox(width: 1),
            Text(
              'MALENS',
              style: AppTextStyles.logo.copyWith(fontSize: fontSize),
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          Text(
            'See the world, Your Way.',
            style: AppTextStyles.tagline.copyWith(fontSize: fontSize * 0.52),
          ),
        ],
      ],
    );
  }
}

class _LensIconPainter extends CustomPainter {
  final Color color;

  const _LensIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;

    // Outer thick circle
    final outerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16;
    canvas.drawCircle(center, outerRadius * 0.88, outerPaint);

    // Inner ring
    final innerRingPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.10;
    canvas.drawCircle(center, outerRadius * 0.52, innerRingPaint);

    // Center pupil / lens center dot
    final centerDotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius * 0.22, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _LensIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
