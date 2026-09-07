import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'color_vision_type.dart';

/// Data model representing a color vision transformation filter.
/// Contains display metadata and a 3x3 linear Daltonization transformation matrix.
class ColorVisionFilter {
  final ColorVisionType type;
  final String name;
  final String shortName;
  final String subtitle;
  final String description;
  final List<double> matrix;

  const ColorVisionFilter({
    required this.type,
    required this.name,
    required this.shortName,
    required this.subtitle,
    required this.description,
    required this.matrix,
  });

  /// Standard 3x3 Identity matrix (Normal View - 0% effect)
  static const List<double> identityMatrix = <double>[
    1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0,
  ];

  /// Interpolates 3x3 matrix values based on severity [intensity] (0.0 = 0% to 1.0 = 100%).
  List<double> getMatrixWithIntensity(double intensity) {
    final clampedIntensity = intensity.clamp(0.0, 1.0);
    if (type == ColorVisionType.normal || clampedIntensity <= 0.0) {
      return identityMatrix;
    }
    if (clampedIntensity >= 1.0) {
      return matrix;
    }

    return List<double>.generate(9, (index) {
      final baseVal = identityMatrix[index];
      final targetVal = matrix[index];
      return baseVal + (targetVal - baseVal) * clampedIntensity;
    });
  }

  /// Converts a 3x3 matrix (9 elements) to a 4x5 ColorFilter matrix (20 elements) for fallback.
  static List<double> toColorMatrix4x5(List<double> mat3x3) {
    return <double>[
      mat3x3[0], mat3x3[1], mat3x3[2], 0.0, 0.0,
      mat3x3[3], mat3x3[4], mat3x3[5], 0.0, 0.0,
      mat3x3[6], mat3x3[7], mat3x3[8], 0.0, 0.0,
      0.0,       0.0,       0.0,       1.0, 0.0,
    ];
  }

  /// Decodes gamma-encoded sRGB [0.0, 1.0] to linear RGB.
  static double srgbToLinear(double c) {
    return c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Encodes linear RGB to gamma-encoded sRGB [0.0, 1.0].
  static double linearToSrgb(double c) {
    if (c <= 0.0) return 0.0;
    return c <= 0.0031308
        ? 12.92 * c
        : 1.055 * math.pow(c, 1.0 / 2.4).toDouble() - 0.055;
  }

  /// Evaluates an sRGB pixel [r, g, b] (values in [0.0, 1.0]) through the full Daltonization pipeline:
  /// 1. Decode sRGB -> Linear
  /// 2. Linear matrix multiplication (with [intensity] interpolation)
  /// 3. Encode Linear -> sRGB
  /// 4. Clamp output strictly to [0.0, 1.0]
  List<double> evaluateRgb(double r, double g, double b, double intensity) {
    final m = getMatrixWithIntensity(intensity);

    final rLin = srgbToLinear(r.clamp(0.0, 1.0));
    final gLin = srgbToLinear(g.clamp(0.0, 1.0));
    final bLin = srgbToLinear(b.clamp(0.0, 1.0));

    final rDaltonLin = m[0] * rLin + m[1] * gLin + m[2] * bLin;
    final gDaltonLin = m[3] * rLin + m[4] * gLin + m[5] * bLin;
    final bDaltonLin = m[6] * rLin + m[7] * gLin + m[8] * bLin;

    final rOut = linearToSrgb(rDaltonLin).clamp(0.0, 1.0);
    final gOut = linearToSrgb(gDaltonLin).clamp(0.0, 1.0);
    final bOut = linearToSrgb(bDaltonLin).clamp(0.0, 1.0);

    return [rOut, gOut, bOut];
  }

  /// Creates a fallback Flutter [ColorFilter] using 4x5 affine matrix transformations
  /// at a specified severity [intensity] (0.0 to 1.0).
  ColorFilter getColorFilterWithIntensity(double intensity) {
    return ColorFilter.matrix(toColorMatrix4x5(getMatrixWithIntensity(intensity)));
  }

  /// Creates default full-intensity Flutter [ColorFilter] fallback.
  ColorFilter get colorFilter =>
      ColorFilter.matrix(toColorMatrix4x5(matrix));
}
