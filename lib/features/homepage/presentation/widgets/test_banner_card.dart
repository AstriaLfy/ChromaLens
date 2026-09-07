import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TestBannerCard extends StatelessWidget {
  final VoidCallback onStartTest;

  const TestBannerCard({
    super.key,
    required this.onStartTest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E5EA),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lakukan Tes Buta Warna',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ChromaLense menyediakan tes buta warna untuk identifikasi awal serta penyesuaian fitur aplikasi',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textGrey,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Purple Button "Ikuti tes buta warna >"
          ElevatedButton(
            onPressed: onStartTest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ikuti tes buta warna',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
