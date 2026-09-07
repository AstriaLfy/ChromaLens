import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/config/router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/widgets/auth_back_button.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_settings_card.dart';
import '../widgets/profile_test_banner_card.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const ProfileScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(LoadProfile()),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAFAFC),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: AuthBackButton(
              onPressed: () {
                if (onBackToHome != null) {
                  onBackToHome!();
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          centerTitle: true,
          title: const Text(
            'Profil Pengguna',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.brandPurple,
                ),
              );
            }

            final profile = (state is ProfileLoaded)
                ? state.profile
                : const UserProfileEntity(
                    name: 'Sung Jinwoo',
                    email: 'jinwoganteng@gmail.com',
                    colorblindType: 'Deuteranomaly',
                    joinedDate: '19 Agt 1999',
                    notificationEnabled: true,
                    language: 'Indonesia',
                  );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 1. Profile Header Card
                  ProfileHeaderCard(profile: profile),
                  const SizedBox(height: 16),

                  // 2. Hasil Tes Banner
                  ProfileTestBannerCard(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.profileTestResult,
                        arguments: {
                          'testResult': sl<TokenStorage>().getTestResult(),
                          'profile': profile,
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Settings List Card
                  ProfileSettingsCard(
                    profile: profile,
                    onNotificationChanged: (val) {
                      context
                          .read<ProfileBloc>()
                          .add(ToggleNotification(val));
                    },
                    onAboutTap: () {
                      _showAboutDialog(context);
                    },
                    onEditProfileTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur Edit Profil segera hadir'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutConfirmation(context),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        'Keluar dari Akun',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'ChromaLens',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.brandPurple,
          ),
        ),
        content: const Text(
          'Aplikasi kamera koreksi warna adaptif dengan algoritma LMS Daltonization dan klasifikasi tes buta warna Ishihara.\n\nVersi 1.0.0',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Tutup',
              style: TextStyle(
                color: AppColors.brandPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar dari Akun',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ChromaLens?',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await sl<TokenStorage>().clearTokens();
              if (context.mounted) {
                context.read<AuthBloc>().add(const LogoutRequested());
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
