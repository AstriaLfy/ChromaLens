import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/token_storage.dart';
import '../widgets/home_header_greeting.dart';
import '../widgets/home_hero_camera_card.dart';
import '../widgets/test_banner_card.dart';
import '../widgets/vision_profile_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenCamera;

  const HomeScreen({
    super.key,
    required this.onOpenCamera,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenStorage = sl<TokenStorage>();
    final userName = tokenStorage.getUserName() ?? 'Pengguna';
    final conditionName =
        tokenStorage.getConditionType() ?? 'Deuteranomaly';
    final conditionDescription = tokenStorage.getConditionDescription() ??
        'Bentuk buta warna yang umum untuk kesulitan membedakan merah-hijau';
    final lastTestResult = tokenStorage.getTestResult();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Greeting & Notification
              HomeHeaderGreeting(
                userName: userName,
                greeting: _getGreeting(),
              ),
              const SizedBox(height: 18),

              // Hero Purple Camera Card
              HomeHeroCameraCard(
                onOpenCamera: widget.onOpenCamera,
              ),
              const SizedBox(height: 18),

              // Vision Profile Card
              VisionProfileCard(
                conditionName: conditionName,
                description: conditionDescription,
                onDetailTap: () {
                  Navigator.pushNamed(
                    context,
                    '/profile_test_result',
                    arguments: lastTestResult,
                  ).then((_) {
                    if (mounted) setState(() {});
                  });
                },
              ),
              const SizedBox(height: 18),

              // Test Buta Warna Banner Card
              TestBannerCard(
                onStartTest: () {
                  Navigator.pushNamed(context, '/colorblind_test').then((_) {
                    if (mounted) setState(() {});
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
