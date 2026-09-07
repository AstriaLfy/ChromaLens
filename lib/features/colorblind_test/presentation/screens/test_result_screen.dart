import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/test_result_entity.dart';
import '../widgets/result_info_row.dart';

class TestResultScreen extends StatelessWidget {
  final TestResultEntity result;

  const TestResultScreen({
    super.key,
    required this.result,
  });

  String _formatDate(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final day = dt.day;
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Title
              const SizedBox(height: 12),
              const Text(
                'Analisis Berhasil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 32),

              // Glowing Purple Halo with Checkmark
              Center(
                child: SizedBox(
                  width: 170,
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radial Gradient Aura Glow
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.brandPurple.withValues(alpha: 0.55),
                              AppColors.brandPurple.withValues(alpha: 0.20),
                              Colors.transparent,
                            ],
                            stops: const [0.2, 0.65, 1.0],
                          ),
                        ),
                      ),
                      // Inner Solid Icon
                      const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 54,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // "Anda terdeteksi"
              const Text(
                'Anda terdeteksi',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 6),

              // Diagnosis Name
              Text(
                result.diagnosis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  result.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Summary Details Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5E5EA),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    ResultInfoRow(
                      icon: Icons.graphic_eq_rounded,
                      label: 'Warna yang terdampak',
                      value: result.affectedColors,
                    ),
                    ResultInfoRow(
                      icon: Icons.grid_view_rounded,
                      label: 'Kategori',
                      value: result.category,
                    ),
                    ResultInfoRow(
                      icon: Icons.language_rounded,
                      label: 'Tanggal Tes',
                      value: _formatDate(result.testDate),
                    ),
                    ResultInfoRow(
                      icon: Icons.grid_3x3_rounded,
                      label: 'Benar',
                      value: result.scoreFormatted,
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Medical Disclaimer Notice
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.textGrey,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hasil bukan diagnosis medis. Konsultasikan dengan dokter mata untuk hasil lebih akurat.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Action Button "Masuk ke Beranda"
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Masuk ke Beranda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
