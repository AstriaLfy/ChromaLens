import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileSettingsCard extends StatelessWidget {
  final UserProfileEntity profile;
  final ValueChanged<bool> onNotificationChanged;
  final VoidCallback? onAboutTap;
  final VoidCallback? onEditProfileTap;

  const ProfileSettingsCard({
    super.key,
    required this.profile,
    required this.onNotificationChanged,
    this.onAboutTap,
    this.onEditProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E5EA),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          // 1. Mode Buta Warna
          _buildItem(
            icon: Icons.graphic_eq_rounded,
            title: 'Mode Buta Warna',
            trailingText: profile.colorblindType,
          ),
          _buildDivider(),

          // 2. Bahasa
          _buildItem(
            icon: Icons.language_rounded,
            title: 'Bahasa',
            trailingText: profile.language,
          ),
          _buildDivider(),

          // 3. Notifikasi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 22,
                  color: AppColors.textDark,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 0.85,
                  child: Switch.adaptive(
                    value: profile.notificationEnabled,
                    activeTrackColor: const Color(0xFF34C759),
                    onChanged: onNotificationChanged,
                  ),
                ),
              ],
            ),
          ),
          _buildDivider(),

          // 4. Tentang Aplikasi
          _buildItem(
            icon: Icons.info_outline_rounded,
            title: 'Tentang Aplikasi',
            hasChevron: true,
            onTap: onAboutTap,
          ),
          _buildDivider(),

          // 5. Edit Profil
          _buildItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profil',
            hasChevron: true,
            onTap: onEditProfileTap,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    String? trailingText,
    bool hasChevron = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: AppColors.textDark,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textDark,
                ),
              ),
            if (hasChevron)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textGrey,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.7,
      color: Color(0xFFF2F2F7),
      indent: 16,
      endIndent: 16,
    );
  }
}
