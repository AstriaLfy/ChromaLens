import 'dart:math';
import 'package:flutter/material.dart';

class IshiharaPlateWidget extends StatelessWidget {
  final String numberText;
  final String? imageUrl;
  final double size;

  const IshiharaPlateWidget({
    super.key,
    required this.numberText,
    this.imageUrl,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    Widget plateContent;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      plateContent = Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF6B4EFF),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Fallback to custom painter if image fails to load
          return CustomPaint(
            size: Size(size, size),
            painter: _IshiharaPainter(
              numberText: numberText,
            ),
          );
        },
      );
    } else {
      plateContent = CustomPaint(
        size: Size(size, size),
        painter: _IshiharaPainter(
          numberText: numberText,
        ),
      );
    }

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: plateContent,
        ),
      ),
    );
  }
}

class _IshiharaPainter extends CustomPainter {
  final String numberText;

  _IshiharaPainter({
    required this.numberText,
  });

  static const List<Color> _backgroundColors = [
    Color(0xFF7A8B47),
    Color(0xFF8C9F53),
    Color(0xFF9EAE61),
    Color(0xFFAEB870),
    Color(0xFFBDC782),
    Color(0xFFCDD693),
    Color(0xFFD6DF9C),
    Color(0xFF9AA456),
    Color(0xFFB5BE68),
  ];

  static const List<Color> _digitColors = [
    Color(0xFFE05A47),
    Color(0xFFE86A55),
    Color(0xFFEE7962),
    Color(0xFFF38B73),
    Color(0xFFF89A84),
    Color(0xFFD84E3A),
    Color(0xFFE76550),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Use a fixed random seed based on the numberText so the pattern is stable for each plate
    final random = Random(numberText.hashCode ^ 9923);

    // 1. Build Text Path for the number to detect which dots fall inside the digit
    final textPainter = TextPainter(
      text: TextSpan(
        text: numberText,
        style: TextStyle(
          fontSize: size.width * 0.48,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );

    // Render text to offscreen picture to do hit testing via path
    // We can extract text glyphs or test using distance to approximate strokes
    // Or render text to a recorder and use alpha/pixel testing, or simple path:
    // In Flutter, we can convert TextPainter to Path or use simple digit segment bounds
    // Let's create a custom text path using TextPainter paragraph or path
    // Alternatively, we draw the text into a small 100x100 mask or use font layout:
    // To ensure 100% deterministic and smooth execution across all Flutter platforms,
    // let's sample points using standard hexagonal grid:
    final step = size.width * 0.042;
    final dotMaxRadius = step * 0.58;
    final dotMinRadius = step * 0.32;

    // We can prepare digit bounds test:
    // Let's create a quick hit test using a Picture or simple bounding boxes/path
    // Even better: Flutter's TextPainter can draw into a layer or we can measure character boxes!
    // Let's create an offscreen canvas test or direct stroke path:
    final digitRects = _getDigitRects(size, textPainter.width, textPainter.height);

    for (double y = dotMaxRadius; y <= size.height; y += step * 0.86) {
      final isOddRow = ((y / (step * 0.86)).round() % 2) == 1;
      final startX = isOddRow ? (step * 0.5) : 0.0;

      for (double x = startX; x <= size.width; x += step) {
        // Jitter point position organically
        final jitterX = (random.nextDouble() - 0.5) * (step * 0.45);
        final jitterY = (random.nextDouble() - 0.5) * (step * 0.45);
        final pt = Offset(x + jitterX, y + jitterY);

        final distFromCenter = (pt - center).distance;
        if (distFromCenter + dotMaxRadius > radius * 0.98) {
          continue; // Outside plate circle
        }

        // Check if inside digit area
        final isInsideDigit = _isPointInNumber(
          pt,
          textOffset,
          textPainter.width,
          textPainter.height,
          digitRects,
          random,
        );

        final colorList = isInsideDigit ? _digitColors : _backgroundColors;
        final color = colorList[random.nextInt(colorList.length)];
        final dotRadius = dotMinRadius + random.nextDouble() * (dotMaxRadius - dotMinRadius);

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.drawCircle(pt, dotRadius, paint);
      }
    }
  }

  List<Rect> _getDigitRects(Size size, double textWidth, double textHeight) {
    final center = Offset(size.width / 2, size.height / 2);
    return [
      Rect.fromCenter(
        center: center,
        width: textWidth * 1.05,
        height: textHeight * 0.95,
      )
    ];
  }

  bool _isPointInNumber(
    Offset pt,
    Offset textOffset,
    double textW,
    double textH,
    List<Rect> digitRects,
    Random random,
  ) {
    final localX = pt.dx - textOffset.dx;
    final localY = pt.dy - textOffset.dy;

    if (localX < 0 || localX > textW || localY < 0 || localY > textH) {
      return false;
    }

    final nx = localX / textW;
    final ny = localY / textH;

    // Pattern recognition for standard Ishihara numbers
    switch (numberText) {
      case '12':
        // Digit 1 (left: nx 0.12 - 0.38) and Digit 2 (right: nx 0.52 - 0.92)
        final in1 = (nx >= 0.16 && nx <= 0.34 && ny >= 0.15 && ny <= 0.85);
        final in2 = (nx >= 0.52 && nx <= 0.88) &&
            ((ny >= 0.15 && ny <= 0.35) || // top bar
             (ny >= 0.35 && ny <= 0.65 && nx >= 0.70) || // right curve
             (ny >= 0.65 && ny <= 0.75 && (nx + ny * 0.5 >= 0.95 && nx + ny * 0.5 <= 1.25)) || // diagonal
             (ny >= 0.75 && ny <= 0.88)); // bottom bar
        return in1 || in2;

      case '8':
        // Digit 8: outer loop top and bottom with hollow centers
        final inOuter = (nx >= 0.22 && nx <= 0.78 && ny >= 0.15 && ny <= 0.85);
        final inTopHole = (nx >= 0.36 && nx <= 0.64 && ny >= 0.26 && ny <= 0.44);
        final inBottomHole = (nx >= 0.34 && nx <= 0.66 && ny >= 0.56 && ny <= 0.74);
        return inOuter && !inTopHole && !inBottomHole;

      case '26':
        // Digit 2 (left) and Digit 6 (right)
        final in2 = (nx >= 0.12 && nx <= 0.46) &&
            ((ny >= 0.15 && ny <= 0.35) ||
             (ny >= 0.35 && ny <= 0.65 && nx >= 0.30) ||
             (ny >= 0.65 && ny <= 0.75 && nx <= 0.35) ||
             (ny >= 0.75 && ny <= 0.88));
        final in6 = (nx >= 0.54 && nx <= 0.88) &&
            ((nx >= 0.54 && nx <= 0.70 && ny >= 0.20 && ny <= 0.85) || // left spine
             (ny >= 0.15 && ny <= 0.32 && nx <= 0.82) || // top hook
             (ny >= 0.50 && ny <= 0.85 && nx >= 0.54 && nx <= 0.88 &&
              !(nx >= 0.66 && nx <= 0.76 && ny >= 0.60 && ny <= 0.75))); // bottom loop with hole
        return in2 || in6;

      default:
        // Generic digit display
        final inCenter = (nx >= 0.25 && nx <= 0.75 && ny >= 0.20 && ny <= 0.80);
        final hole = (nx >= 0.40 && nx <= 0.60 && ny >= 0.40 && ny <= 0.60);
        return inCenter && !hole;
    }
  }

  @override
  bool shouldRepaint(covariant _IshiharaPainter oldDelegate) =>
      oldDelegate.numberText != numberText;
}
