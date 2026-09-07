import 'package:flutter/material.dart';
import '../../../homepage/presentation/screens/home_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/offline_mode_banner.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialTab;
  final bool isOfflineMode;

  const MainNavigationShell({
    super.key,
    this.initialTab = 0,
    this.isOfflineMode = false,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTab;

    if (widget.isOfflineMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOfflineInfoDialog();
      });
    }
  }

  void _showOfflineInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: Colors.orange.shade700,
              size: 24,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Mode Offline Aktif',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Kamu sedang menggunakan mode offline. '
          'Fitur kamera tetap bisa digunakan.\n\n'
          'Untuk beralih ke mode online, ketuk banner di bagian atas layar.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Mengerti',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSwitchToOnline() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      if (widget.isOfflineMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil tidak tersedia dalam mode offline'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      // Profile Tab
      setState(() => _currentTabIndex = 2);
    } else {
      setState(() => _currentTabIndex = 0);
    }
  }

  void _onOpenCamera() {
    Navigator.pushNamed(context, '/camera');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Offline Mode Banner at the top
          if (widget.isOfflineMode)
            SafeArea(
              bottom: false,
              child: OfflineModeBanner(
                onSwitchMode: _onSwitchToOnline,
              ),
            ),

          // Main content
          Expanded(
            child: widget.isOfflineMode
                ? SafeArea(
                    top: false,
                    child: IndexedStack(
                      index: 0,
                      children: [
                        HomeScreen(onOpenCamera: _onOpenCamera),
                      ],
                    ),
                  )
                : SafeArea(
                    child: IndexedStack(
                      index: _currentTabIndex == 2 ? 1 : 0,
                      children: [
                        HomeScreen(onOpenCamera: _onOpenCamera),
                        ProfileScreen(
                          onBackToHome: () =>
                              setState(() => _currentTabIndex = 0),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentTabIndex,
        onTabSelected: _onTabSelected,
        onCameraTap: _onOpenCamera,
      ),
    );
  }
}
