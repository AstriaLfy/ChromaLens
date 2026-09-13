import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'color_vision_type.dart';

/// Data model representing a color vision transformation filter.
/// Contains display metadata, a 3x3 linear transformation matrix,
/// and optional achromatopsia mode flags.
class ColorVisionFilter {
  final ColorVisionType type;
  final String name;
  final String shortName;
  final String subtitle;
  final String description;
  final List<double> matrix;

  /// Whether this filter uses grayscale conversion instead of matrix multiplication.
  final bool isAchromat;

  /// Blend ratio between original color and grayscale (0.0–1.0).
  /// Only used when [isAchromat] is true. Defaults to 1.0 (full grayscale).
  final double achromatBlendRatio;

  const ColorVisionFilter({
    required this.type,
    required this.name,
    required this.shortName,
    required this.subtitle,
    required this.description,
    required this.matrix,
    this.isAchromat = false,
    this.achromatBlendRatio = 1.0,
  });

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

  /// Converts a 3x3 matrix (9 elements) to a 4x5 ColorFilter matrix (20 elements).
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

  /// Evaluates an sRGB pixel [r, g, b] (values in [0.0, 1.0]) through the full pipeline:
  /// 1. Decode sRGB → Linear
  /// 2. Apply transformation (matrix or grayscale+contrast)
  /// 3. Encode Linear → sRGB
  /// 4. Clamp output to [0.0, 1.0]
  List<double> evaluateRgb(double r, double g, double b, double intensity) {
    final clampedIntensity = intensity.clamp(0.0, 1.0);

    if (type == ColorVisionType.normal || clampedIntensity <= 0.0) {
      return [r.clamp(0.0, 1.0), g.clamp(0.0, 1.0), b.clamp(0.0, 1.0)];
    }

    final rLin = srgbToLinear(r.clamp(0.0, 1.0));
    final gLin = srgbToLinear(g.clamp(0.0, 1.0));
    final bLin = srgbToLinear(b.clamp(0.0, 1.0));

    List<double> processedLin;

    if (isAchromat) {
      processedLin = _evaluateAchromat(rLin, gLin, bLin, clampedIntensity);
    } else {
      processedLin = _evaluateMatrix(rLin, gLin, bLin, clampedIntensity);
    }

    return [
      linearToSrgb(processedLin[0]).clamp(0.0, 1.0),
      linearToSrgb(processedLin[1]).clamp(0.0, 1.0),
      linearToSrgb(processedLin[2]).clamp(0.0, 1.0),
    ];
  }

  List<double> _evaluateMatrix(
    double rLin, double gLin, double bLin, double intensity,
  ) {
    final m = getMatrixWithIntensity(intensity);

    final rProc = m[0] * rLin + m[1] * gLin + m[2] * bLin;
    final gProc = m[3] * rLin + m[4] * gLin + m[5] * bLin;
    final bProc = m[6] * rLin + m[7] * gLin + m[8] * bLin;

    return [rProc, gProc, bProc];
  }

  List<double> _evaluateAchromat(
    double rLin, double gLin, double bLin, double intensity,
  ) {
    // ITU-R BT.709 luminance
    final yLin = 0.2126 * rLin + 0.7152 * gLin + 0.0722 * bLin;

    // Grayscale with contrast boost (the matrix encodes the contrast boost)
    final m = getMatrixWithIntensity(intensity);
    final boostedY = m[0] * yLin; // diagonal element carries contrast scale

    // Blend between original color and boosted grayscale
    final blendRatio = achromatBlendRatio * intensity;
    final resultR = rLin + (boostedY - rLin) * blendRatio;
    final resultG = gLin + (boostedY - gLin) * blendRatio;
    final resultB = bLin + (boostedY - bLin) * blendRatio;

    return [resultR, resultG, resultB];
  }

  /// Creates a fallback Flutter [ColorFilter] using 4x5 affine matrix.
  ColorFilter getColorFilterWithIntensity(double intensity) {
    if (isAchromat) {
      // Grayscale matrix for ColorFilter fallback
      final m = getMatrixWithIntensity(intensity);
      final contrastDiag = m[0];
      final grayMatrix = <double>[
        contrastDiag * 0.2126, contrastDiag * 0.7152, contrastDiag * 0.0722, 0.0, 0.0,
        contrastDiag * 0.2126, contrastDiag * 0.7152, contrastDiag * 0.0722, 0.0, 0.0,
        contrastDiag * 0.2126, contrastDiag * 0.7152, contrastDiag * 0.0722, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ];
      return ColorFilter.matrix(grayMatrix);
    }
    return ColorFilter.matrix(toColorMatrix4x5(getMatrixWithIntensity(intensity)));
  }

  ColorFilter get colorFilter =>
      ColorFilter.matrix(toColorMatrix4x5(matrix));
}
