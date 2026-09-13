import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SelectConditionScreen extends StatelessWidget {
  const SelectConditionScreen({super.key});

  void _onManualSelect(BuildContext context) {
    Navigator.pushNamed(context, '/manual_select');
  }

  void _onStartTest(BuildContext context) {
    Navigator.pushNamed(context, '/colorblind_test');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Headline
              const Text(
                'Apakah Anda sudah\nmengetahui jenis gangguan\npenglihatan warna Anda?',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Bantu kami memberikan pengalaman terbaik untuk dirimu melihat warna dengan memberitahu kami tipe buta warna anda.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textDark,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 36),

              // Button "Pilih Manual"
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _onManualSelect(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Pilih Manual',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Divider "Belum tau?"
              Row(
                children: const [
                  Expanded(
                    child: Divider(
                      color: AppColors.dividerLine,
                      thickness: 1.2,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Belum tau?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.dividerLine,
                      thickness: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Big Button "Ikuti Tes Buta Warna →"
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _onStartTest(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ikuti Tes Buta Warna →',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Footnote Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.textDark,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                          height: 1.35,
                        ),
                        children: [
                          TextSpan(
                            text: 'Pilihan anda tetap dapat diubah melalui ',
                          ),
                          TextSpan(
                            text: 'Profile > Golongan Buta Warna',
                            style: TextStyle(
                              color: AppColors.brandPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}