import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CameraPermissionDialog extends StatelessWidget {
  final VoidCallback onDeny;
  final VoidCallback onAllow;

  const CameraPermissionDialog({
    super.key,
    required this.onDeny,
    required this.onAllow,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onDeny,
    required VoidCallback onAllow,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CameraPermissionDialog(
        onDeny: onDeny,
        onAllow: onAllow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              children: const [
                // Top Camera Icon
                Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.brandPurple,
                  size: 38,
                ),
                SizedBox(height: 16),

                // Title
                Text(
                  '“ChromaLense” ingin\nmengakses kamera anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 10),

                // Subtitle
                Text(
                  'Aplikasi membutuhkan akses kamera untuk mengakses filter ke ponsel anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textGrey,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFE5E5EA),
          ),

          // Action Buttons (Tolak vs Izinkan)
          SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onDeny,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Tolak',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 0.8,
                  color: Color(0xFFE5E5EA),
                ),
                Expanded(
                  child: InkWell(
                    onTap: onAllow,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Izinkan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandPurple,
                        ),
                      ),
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
