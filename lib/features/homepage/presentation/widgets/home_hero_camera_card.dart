import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HomeHeroCameraCard extends StatelessWidget {
  final VoidCallback onOpenCamera;

  const HomeHeroCameraCard({
    super.key,
    required this.onOpenCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B539B),
            Color(0xFF513A7E),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background geometric mesh pattern
          Positioned(
            right: -20,
            top: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.18,
              child: CustomPaint(
                size: const Size(180, 160),
                painter: _MeshLinePainter(),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lihat warna dengan\nlebih jelas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pengaturan warna yang disesuaikan untuk kamu melihat perbedaannya dengan lebih jelas.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),

                // White pill button "Buka Kamera >"
                GestureDetector(
                  onTap: onOpenCamera,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 17,
                          color: AppColors.brandPurple,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Buka Kamera',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandPurple,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.brandPurple,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeshLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final points = [
      Offset(size.width * 0.2, size.height * 0.1),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.8),
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.45),
    ];

    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        canvas.drawLine(points[i], points[j], paint);
      }
      canvas.drawCircle(points[i], 2.5, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
