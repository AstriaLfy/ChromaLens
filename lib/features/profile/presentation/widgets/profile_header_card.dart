import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserProfileEntity profile;

  const ProfileHeaderCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
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
          // Avatar
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEDE9FE),
              border: Border.all(
                color: AppColors.brandPurple.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: profile.avatarUrl != null
                  ? Image.network(
                      profile.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(height: 12),

          // User Name
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 3),

          // User Email
          Text(
            profile.email,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 18),

          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFF0F0F2),
          ),
          const SizedBox(height: 14),

          // Two-column section: Tipe Buta Warna & Bergabung Sejak
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Tipe Buta Warna',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.colorblindType,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Vertical Divider
                Container(
                  width: 1,
                  height: 36,
                  color: const Color(0xFFF0F0F2),
                ),

                // Right Column
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Bergabung Sejak',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.joinedDate,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return const Center(
      child: Icon(
        Icons.person_rounded,
        size: 44,
        color: AppColors.brandPurple,
      ),
    );
  }
}
