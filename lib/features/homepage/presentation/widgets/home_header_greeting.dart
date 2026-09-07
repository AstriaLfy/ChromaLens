import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HomeHeaderGreeting extends StatelessWidget {
  final String userName;
  final String greeting;
  final VoidCallback? onNotificationTap;

  const HomeHeaderGreeting({
    super.key,
    this.userName = 'Jinwoo',
    this.greeting = 'Selamat Pagi',
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar Circle
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.brandPurple.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.brandPurple.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const ClipOval(
            child: Icon(
              Icons.person_rounded,
              color: AppColors.brandPurple,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $userName!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Siap melihat warna baru hari ini?',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),

        // Notification Icon
        IconButton(
          onPressed: onNotificationTap ?? () {},
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textDark,
            size: 26,
          ),
        ),
      ],
    );
  }
}
