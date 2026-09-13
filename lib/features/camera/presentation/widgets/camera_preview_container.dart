import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/utils/camera_frame_converter.dart';
import '../../domain/models/color_vision_filter.dart';

/// Full-screen live camera preview wrapper.
/// Fits camera feed while preserving aspect ratio and applies real-time GPU [FragmentProgram]
/// Daltonization shader with dynamic severity [intensity].
///
/// Unlike [CameraPreview], this uses the image stream pipeline: it converts
/// each [CameraImage] frame into a [ui.Image] (rotated upright from the sensor
/// orientation) and renders it through [RawImage]. This is required because
/// `ImageFiltered`/`ImageFilter.shader` do not composite against the platform
/// camera `Texture` on Impeller backends, so the shader has no visible effect
/// with [CameraPreview]. The surrounding aspect/scale/clip layout is kept
/// identical so the on-screen framing does not change.
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

  ui.Image? _currentImage;
  bool _isStreamStarted = false;
  bool _isProcessingFrame = false;

  @override
  void initState() {
    super.initState();
    _loadShaderIfNeeded();
    _startImageStream();
  }

  @override
  void didUpdateWidget(CameraPreviewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _stopImageStream(oldWidget.controller);
      _currentImage?.dispose();
      _currentImage = null;
      _isStreamStarted = false;
      _startImageStream();
    }
  }

  @override
  void dispose() {
    _stopImageStream(widget.controller);
    _currentImage?.dispose();
    super.dispose();
  }

  /// Starts streaming frames from the camera.
  ///
  /// Throwing is expected if the controller is not initialized yet or stream
  /// is already active; errors are logged but never surfaced to the UI so the
  /// rest of the screen keeps working.
  Future<void> _startImageStream() async {
    if (_isStreamStarted) return;
    _isStreamStarted = true;
    try {
      await widget.controller.startImageStream(_onFrameAvailable);
    } catch (error) {
      debugPrint('Image stream not started: $error');
    }
  }

  void _stopImageStream(CameraController controller) {
    try {
      if (controller.value.isStreamingImages) {
        controller.stopImageStream();
      }
    } catch (error) {
      debugPrint('Image stream stop note: $error');
    }
  }

  /// Converts the latest sensor-oriented frame to an upright [ui.Image] and
  /// replaces the preview. Frames are dropped while a conversion is running;
  /// the platform already delivers only the latest frame in this scenario.
  Future<void> _onFrameAvailable(CameraImage frame) async {
    if (_isProcessingFrame || !mounted) return;
    _isProcessingFrame = true;
    try {
      final image = await CameraFrameConverter.toUiImage(
        frame,
        rotationDegrees: _computeRotationDegrees(),
      );
      if (!mounted) {
        image?.dispose();
        return;
      }
      setState(() {
        _currentImage?.dispose();
        _currentImage = image;
      });
    } catch (error) {
      debugPrint('Frame conversion note: $error');
    } finally {
      _isProcessingFrame = false;
    }
  }

  /// Computes the clockwise rotation in degrees required to make a
  /// sensor-oriented frame upright on screen for the current device
  /// orientation, matching the framing `CameraPreview` produces.
  int _computeRotationDegrees() {
    final description = widget.controller.description;
    final deviceDegrees = switch (widget.controller.value.deviceOrientation) {
      DeviceOrientation.portraitUp => 0,
      DeviceOrientation.landscapeLeft => 90,
      DeviceOrientation.portraitDown => 180,
      DeviceOrientation.landscapeRight => 270,
    };
    final isFrontCamera =
        description.lensDirection == CameraLensDirection.front;
    if (isFrontCamera) {
      return (description.sensorOrientation + deviceDegrees) % 360;
    }
    return (description.sensorOrientation - deviceDegrees + 360) % 360;
  }

  void _loadShaderIfNeeded() {
    if (_cachedProgram != null || _isLoadingProgram) return;

    if (!ui.ImageFilter.isShaderFilterSupported) {
      debugPrint('Shader filter not supported on this backend; '
          'falling back to ColorFiltered.');
      return;
    }

    _isLoadingProgram = true;
    ui.FragmentProgram.fromAsset('shaders/daltonization.frag').then((program) {
      debugPrint('Daltonization FragmentProgram loaded.');
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

  /// Maps filter type to the shader's u_type int.
  ///
  /// Shader uniform values:
  /// - 0: normal (passthrough)
  /// - 1: matrix-based filter
  /// - 2: achromatopsia (full grayscale + contrast)
  /// - 3: achromatomaly (partial grayscale + reduced contrast)
  int _getShaderType() {
    if (widget.filter.type.name == 'normal') return 0;
    if (widget.filter.type.name == 'achromatopsia') return 2;
    if (widget.filter.type.name == 'achromatomaly') return 3;
    return 1; // matrix-based
  }

  ui.ImageFilter? _createShaderFilter() {
    final program = _cachedProgram;
    if (program == null || !ui.ImageFilter.isShaderFilterSupported) {
      return null;
    }

    try {
      final shader = program.fragmentShader();

      // Uniform layout:
      // index 0, 1: u_size (vec2 — set automatically by engine)
      // index 2..10: u_m00..u_m22 (3×3 matrix D)
      // index 11: u_intensity (0.0–1.0)
      // index 12: u_type (int as float)
      // index 13: u_achromat_blend (float)

      final matrix = widget.filter.matrix;
      for (var i = 0; i < 9; i++) {
        shader.setFloat(2 + i, matrix[i]);
      }
      shader.setFloat(11, widget.intensity.clamp(0.0, 1.0));
      shader.setFloat(12, _getShaderType().toDouble());
      shader.setFloat(13, widget.filter.achromatBlendRatio);

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
        var scale = size.aspectRatio * widget.controller.value.aspectRatio;
        if (scale < 1) scale = 1 / scale;

        Widget cameraWidget;
        final image = _currentImage;
        if (image != null) {
          cameraWidget = AspectRatio(
            aspectRatio: image.width / image.height,
            child: RawImage(
              image: image,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          );
        } else {
          cameraWidget = const ColoredBox(color: Colors.black);
        }

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