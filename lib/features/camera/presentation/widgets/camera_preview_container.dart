import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../domain/models/color_vision_filter.dart';

/// Full-screen live camera preview wrapper.
/// Fits camera feed while preserving aspect ratio and applies real-time GPU [FragmentProgram]
/// Daltonization shader with dynamic severity [intensity].
class CameraPreviewContainer extends StatefulWidget {
  final CameraController controller;
  final ColorVisionFilter filter;
  final double intensity;

  const CameraPreviewContainer({
    super.key,
    required this.controller,
    required this.filter,
    this.intensity = 1.0,
  });

  @override
  State<CameraPreviewContainer> createState() => _CameraPreviewContainerState();
}

class _CameraPreviewContainerState extends State<CameraPreviewContainer> {
  static ui.FragmentProgram? _cachedProgram;
  static bool _isLoadingProgram = false;

  @override
  void initState() {
    super.initState();
    _loadShaderIfNeeded();
  }

  void _loadShaderIfNeeded() {
    if (_cachedProgram != null || _isLoadingProgram) return;

    // Only load if shader filters are supported on this engine/platform
    if (!ui.ImageFilter.isShaderFilterSupported) return;

    _isLoadingProgram = true;
    ui.FragmentProgram.fromAsset('shaders/daltonization.frag').then((program) {
      if (mounted) {
        setState(() {
          _cachedProgram = program;
        });
      } else {
        _cachedProgram = program;
      }
    }).catchError((error) {
      debugPrint('Failed to load Daltonization FragmentProgram: $error');
    }).whenComplete(() {
      _isLoadingProgram = false;
    });
  }

  ui.ImageFilter? _createShaderFilter() {
    final program = _cachedProgram;
    if (program == null || !ui.ImageFilter.isShaderFilterSupported) {
      return null;
    }

    try {
      final shader = program.fragmentShader();

      // Uniform indices:
      // index 0, 1: u_size (vec2 set automatically by engine in ImageFilter.shader)
      // index 2..10: u_m00..u_m22 (3x3 Daltonization matrix D)
      // index 11: u_intensity (0.0 to 1.0)
      final matrix = widget.filter.matrix;
      for (var i = 0; i < 9; i++) {
        shader.setFloat(2 + i, matrix[i]);
      }
      shader.setFloat(11, widget.intensity.clamp(0.0, 1.0));

      return ui.ImageFilter.shader(shader);
    } catch (e) {
      debugPrint('Failed to create ImageFilter.shader: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white70),
        ),
      );
    }

    final shaderFilter = _createShaderFilter();

    final isFrontCamera =
        widget.controller.description.lensDirection == CameraLensDirection.front;

    Widget previewContent = LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        // controller.value.aspectRatio is height/width for portrait camera
        var scale = size.aspectRatio * widget.controller.value.aspectRatio;
        if (scale < 1) scale = 1 / scale;

        Widget cameraWidget = CameraPreview(widget.controller);

        // Mirror front camera horizontally so it behaves like a natural mirror
        if (isFrontCamera) {
          cameraWidget = Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: cameraWidget,
          );
        }

        return ClipRect(
          child: Transform.scale(
            scale: scale,
            child: Center(
              child: cameraWidget,
            ),
          ),
        );
      },
    );

    // Apply GPU shader if available, otherwise fallback to ColorFiltered
    Widget filteredPreview;
    if (shaderFilter != null) {
      filteredPreview = ImageFiltered(
        imageFilter: shaderFilter,
        child: previewContent,
      );
    } else {
      filteredPreview = ColorFiltered(
        colorFilter: widget.filter.getColorFilterWithIntensity(widget.intensity),
        child: previewContent,
      );
    }

    return Container(
      color: Colors.black,
      child: filteredPreview,
    );
  }
}
