import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/utils/color_vision_filters.dart';
import '../../domain/models/color_vision_filter.dart';
import '../../domain/models/color_vision_type.dart';
import '../widgets/camera_permission_dialog.dart';
import '../widgets/camera_preview_container.dart';
import '../widgets/mode_info_sheet.dart';
import 'camera_permission_denied_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _availableCameras = [];

  bool _permissionGranted = false;
  bool _isOriginalMode = false;
  bool _isTorchOn = false;
  bool _isTorchAvailable = false;
  bool _isInitializing = false;

  ColorVisionFilter _activeFilter = ColorVisionFilters.deuteranopia;
  final double _intensity = 0.85;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestCameraPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (cameraController != null && cameraController.value.isInitialized) {
        cameraController.dispose();
        _controller = null;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null && _permissionGranted && !_isInitializing) {
        _initializeCameraHardware();
      }
    }
  }

  void _requestCameraPermission() {
    CameraPermissionDialog.show(
      context,
      onDeny: () {
        Navigator.pop(context); // Close dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CameraPermissionDeniedScreen(
              onRetry: () {
                Navigator.pop(context); // Back to CameraScreen
                _requestCameraPermission(); // Prompt again
              },
            ),
          ),
        );
      },
      onAllow: () async {
        Navigator.pop(context); // Close dialog
        setState(() {
          _permissionGranted = true;
        });
        try {
          await Permission.camera.request();
        } catch (_) {}
        await _initializeCameraHardware();
      },
    );
  }

  Future<void> _initializeCameraHardware() async {
    if (_isInitializing) return;

    setState(() => _isInitializing = true);

    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        if (mounted) {
          setState(() => _isInitializing = false);
        }
        return;
      }

      final rearIndex = _availableCameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      final cameraToUse =
          rearIndex != -1 ? _availableCameras[rearIndex] : _availableCameras[0];

      final controller = CameraController(
        cameraToUse,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      bool torchSupported = false;
      try {
        await controller.setFlashMode(FlashMode.off);
        torchSupported = true;
      } catch (_) {
        torchSupported = false;
      }

      if (mounted) {
        setState(() {
          _controller = controller;
          _isTorchAvailable = torchSupported;
          _isTorchOn = false;
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('Camera hardware init note: $e');
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _toggleTorch() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        !_isTorchAvailable) {
      return;
    }
    try {
      final next = !_isTorchOn;
      await _controller!.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) {
        setState(() => _isTorchOn = next);
      }
    } catch (_) {}
  }

  Future<void> _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        await _controller!.takePicture();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto berhasil diambil dengan filter Daltonization'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        debugPrint('Failed to capture photo: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shutter ditekan (Simulasi pengambilan foto)'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openInfoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModeInfoSheet(
        currentFilter: _activeFilter,
        onSelectFilter: (newFilter) {
          setState(() {
            _activeFilter = newFilter;
            _isOriginalMode = (newFilter.type == ColorVisionType.normal);
          });
        },
      ),
    );
  }

  void _onColorRecognitionTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.palette_outlined,
                      color: AppColors.brandPurple, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Pengenalan Warna Berbasis Teks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Arahkan kamera ke objek di sekitar Anda. Sistem Daltonization ChromaLens secara otomatis menganalisis dan mendeteksi nama warna secara real-time.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Mengerti'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFilter =
        _isOriginalMode ? ColorVisionFilters.normal : _activeFilter;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Camera Feed with LMS Daltonization Shader / Fallback Placeholder
          Positioned.fill(
            child: _controller != null && _controller!.value.isInitialized
                ? CameraPreviewContainer(
                    controller: _controller!,
                    filter: effectiveFilter,
                    intensity: _intensity,
                  )
                : Container(
                    color: const Color(0xFF1C1C1E),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_rounded,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _permissionGranted
                                ? 'Kamera Aktif\n(Placeholder siap untuk integrasi prototype)'
                                : 'Menunggu Izin Kamera...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.6),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // 2. Top Bar Controls (Back Button, Adjustment Pill Badge, Info Icon)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),

                    // Filter Adjustment Pill Badge
                    GestureDetector(
                      onTap: _openInfoSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _activeFilter.type == ColorVisionType.deuteranopia
                              ? 'Penyesuaian Deuteranomaly'
                              : 'Penyesuaian ${_activeFilter.shortName}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Help / Info Icon
                    GestureDetector(
                      onTap: _openInfoSheet,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Floating Filter Switch Pill (Penyesuaian vs Original) - Directly above bottom dock
          Positioned(
            bottom: 124,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isOriginalMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: !_isOriginalMode
                              ? AppColors.brandPurple
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Penyesuaian',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isOriginalMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isOriginalMode
                              ? AppColors.brandPurple
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Original',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Bottom Control Dock (White Background - Flash, Shutter, Pengenalan warna)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Flash Action
                      GestureDetector(
                        onTap: _toggleTorch,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF4F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isTorchOn
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_off_rounded,
                                color: _isTorchOn
                                    ? Colors.amber.shade700
                                    : AppColors.textDark,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Flash',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Center Shutter Button
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.brandPurple,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.brandPurple,
                              size: 28,
                            ),
                          ),
                        ),
                      ),

                      // Pengenalan warna Action
                      GestureDetector(
                        onTap: _onColorRecognitionTap,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF4F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.colorize_rounded,
                                color: AppColors.textDark,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Pengenalan\nwarna',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
