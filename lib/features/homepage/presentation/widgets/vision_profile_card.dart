import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class VisionProfileCard extends StatelessWidget {
  final String conditionName;
  final String description;
  final VoidCallback? onDetailTap;

  const VisionProfileCard({
    super.key,
    this.conditionName = 'Deuteranomaly',
    this.description =
        'Bentuk buta warna yang umum untuk kesulitan membedakan merah-hijau',
    this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 20,
                        color: AppColors.textDark,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Profil Penglihatanmu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.buttonPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Tes ChromaLens',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipe buta warna',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  conditionName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textDark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFEEEEEE),
          ),

          // Footer link
          InkWell(
            onTap: onDetailTap ?? () {},
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Lihat Detail Profil',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
