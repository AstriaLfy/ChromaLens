import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/utils/color_vision_filters.dart';
import '../../domain/models/color_vision_filter.dart';

/// Modal bottom sheet displaying color assistance lens concept and breakdown.
class ModeInfoSheet extends StatelessWidget {
  final ColorVisionFilter currentFilter;
  final ValueChanged<ColorVisionFilter>? onSelectFilter;

  const ModeInfoSheet({
    super.key,
    required this.currentFilter,
    this.onSelectFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                children: [
                  const Icon(
                    Icons.visibility,
                    color: AppColors.brandPurple,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    currentFilter.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentFilter.subtitle,
                      style: const TextStyle(
                        color: Color(0xFFC4B5FD),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mode Description
              Text(
                currentFilter.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),

              const Text(
                'Digital Color Assistance Concept',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Terinspirasi dari kacamata koreksi warna (seperti Colorlite & EnChroma), kamera ChromaLens bertindak sebagai lensa bantuan digital bagi penyandang buta warna. Alih-alih simulasi, algoritma LMS Daltonization memetakan ulang panjang gelombang warna yang ambigu ke saluran kontras terlihat secara real-time.',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Lensa Bantuan yang Tersedia',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Modes list
              ...ColorVisionFilters.availableFilters.map((f) {
                final isCurrent = f.type == currentFilter.type;
                return InkWell(
                  onTap: () {
                    onSelectFilter?.call(f);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.brandPurple.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrent
                          ? Border.all(color: AppColors.brandPurple, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCurrent
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isCurrent
                              ? AppColors.brandPurple
                              : Colors.white38,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${f.name} (${f.subtitle})',
                                style: TextStyle(
                                  color: isCurrent
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                f.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.brandPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.brandPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFFC4B5FD),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pemberitahuan: Lensa kamera digital ini adalah alat bantu aksesibilitas untuk diferensiasi warna. Meskipun Daltonization meningkatkan kontras spektral, konsultasi dengan tenaga medis mata tetap disarankan untuk pemeriksaan klinis.',
                        style: TextStyle(
                          color: Color(0xFFEDE9FE),
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
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
