import '../../domain/models/color_vision_filter.dart';
import '../../domain/models/color_vision_type.dart';

/// Repository of real-time color vision correction & assistance filters.
///
/// All matrices operate in **linear RGB** space. The shader pipeline handles
/// sRGB decode → linear → matrix → sRGB encode → clamp.
///
/// For Achromatopsia/Achromatomaly, the shader performs grayscale conversion
/// and contrast boost instead of matrix multiplication.
class ColorVisionFilters {
  ColorVisionFilters._();

  // ── Matrix definitions (linear RGB space) ──────────────────────────────

  static const ColorVisionFilter normal = ColorVisionFilter(
    type: ColorVisionType.normal,
    name: 'Normal View',
    shortName: 'Normal',
    subtitle: 'Natural Feed',
    description: 'Standard unfiltered camera view for natural color inspection.',
    matrix: <double>[
      1.0, 0.0, 0.0,
      0.0, 1.0, 0.0,
      0.0, 0.0, 1.0,
    ],
  );

  static const ColorVisionFilter protanomaly = ColorVisionFilter(
    type: ColorVisionType.protanomaly,
    name: 'Protanomaly Assist',
    shortName: 'Protanomaly',
    subtitle: 'Mild Red Correction',
    description:
        'Digital correction for mild red deficiency (Protanomaly). '
        'Shifts red channel information into green and blue for better differentiation.',
    matrix: <double>[
      1.0000, 0.0000, 0.0000,
      0.3297, 0.6319, 0.0384,
      0.4376, -0.5161, 1.0785,
    ],
  );

  static const ColorVisionFilter protanopia = ColorVisionFilter(
    type: ColorVisionType.protanopia,
    name: 'Protanopia Assist',
    shortName: 'Protanopia',
    subtitle: 'Red Correction Lens',
    description:
        'Digital correction for total red-blindness (Protanopia). '
        'Projects red details into visible green and blue channels.',
    matrix: <double>[
      1.0000, 0.0000, 0.0000,
      0.4789, 0.4769, 0.0442,
      0.5973, -0.6887, 1.0914,
    ],
  );

  static const ColorVisionFilter deuteranomaly = ColorVisionFilter(
    type: ColorVisionType.deuteranomaly,
    name: 'Deuteranomaly Assist',
    shortName: 'Deuteranomaly',
    subtitle: 'Mild Green Correction',
    description:
        'Digital correction for mild green deficiency (Deuteranomaly). '
        'Differentiates green and red by shifting green info into red and blue channels.',
    matrix: <double>[
      1.0000, 0.0000, 0.0000,
      0.1456, 0.7728, 0.0816,
      0.3619, -0.5033, 1.1414,
    ],
  );

  static const ColorVisionFilter deuteranopia = ColorVisionFilter(
    type: ColorVisionType.deuteranopia,
    name: 'Deuteranopia Assist',
    shortName: 'Deuteranopia',
    subtitle: 'Green Correction Lens',
    description:
        'Digital correction for total green-blindness (Deuteranopia). '
        'Shifts green and red light details into distinguishable spectrums.',
    matrix: <double>[
      1.0000, 0.0000, 0.0000,
      0.1628, 0.7250, 0.1122,
      0.4547, -0.6454, 1.1907,
    ],
  );

  static const ColorVisionFilter tritanomaly = ColorVisionFilter(
    type: ColorVisionType.tritanomaly,
    name: 'Tritanomaly Assist',
    shortName: 'Tritanomaly',
    subtitle: 'Mild Blue Correction',
    description:
        'Digital correction for mild blue deficiency (Tritanomaly). '
        'Re-maps blue and yellow details into distinguishable red and green spectrums.',
    matrix: <double>[
      1.0000, 0.0000, 0.0000,
      -0.0414, 1.0610, -0.0196,
      -0.0748, -0.2853, 1.3601,
    ],
  );

  static const ColorVisionFilter tritanopia = ColorVisionFilter(
    type: ColorVisionType.tritanopia,
    name: 'Tritanopia Assist',
    shortName: 'Tritanopia',
    subtitle: 'Blue Correction Lens',
    description:
        'Digital correction for total blue-blindness (Tritanopia). '
        'Re-maps blue and yellow light details into distinguishable red and green spectrums.',
    matrix: <double>[
      1.0000, 0.0000, 0.0000,
      -0.1005, 1.1229, -0.0225,
      -0.1836, -0.6376, 1.8212,
    ],
  );

  /// Full achromatopsia: contrast-boost matrix applied to grayscale luminance.
  /// The shader converts to grayscale (Y = 0.2126R + 0.7152G + 0.0722B),
  /// then applies this contrast boost in linear space.
  static const ColorVisionFilter achromatopsia = ColorVisionFilter(
    type: ColorVisionType.achromatopsia,
    name: 'Contrast Assist (Full)',
    shortName: 'Achromatopsia',
    subtitle: 'Monochrome Detail Lens',
    description:
        'High-contrast monochrome lens for Total Colorblindness (Achromatopsia). '
        'Sharpens lightness and texture separation between adjacent objects.',
    matrix: <double>[
      1.35, -0.15, -0.20,
      -0.15, 1.35, -0.20,
      -0.20, -0.15, 1.35,
    ],
    isAchromat: true,
  );

  /// Partial achromatopsia: lighter contrast boost, 55% grayscale blend.
  static const ColorVisionFilter achromatomaly = ColorVisionFilter(
    type: ColorVisionType.achromatomaly,
    name: 'Contrast Assist (Partial)',
    shortName: 'Achromatomaly',
    subtitle: 'Partial Monochrome Lens',
    description:
        'Partial grayscale blend lens for Achromatomaly. '
        'Retains some color information while enhancing contrast for better detail separation.',
    matrix: <double>[
      1.15, -0.08, -0.07,
      -0.08, 1.15, -0.07,
      -0.07, -0.08, 1.15,
    ],
    isAchromat: true,
    achromatBlendRatio: 0.55,
  );

  // ── Collection ─────────────────────────────────────────────────────────

  static const List<ColorVisionFilter> availableFilters = [
    normal,
    protanomaly,
    protanopia,
    deuteranomaly,
    deuteranopia,
    tritanomaly,
    tritanopia,
    achromatopsia,
    achromatomaly,
  ];

  /// Retrieves filter by [ColorVisionType].
  static ColorVisionFilter getFilter(ColorVisionType type) {
    return availableFilters.firstWhere(
      (f) => f.type == type,
      orElse: () => normal,
    );
  }

  /// Resolves a stored condition string (from SharedPreferences) to a
  /// [ColorVisionType]. Handles all known storage formats:
  /// - Select condition: `'Deuteranopia (Buta Warna Hijau)'`
  /// - Auth API / server: `'deuteranopia'`, `'protanopia'`
  /// - Colorblind test: `'Deuteranomaly'`, `'Monokromasi'`
  /// Returns [ColorVisionType.normal] as fallback for null/unrecognized values.
  static ColorVisionType resolveFromStoredString(String? stored) {
    if (stored == null || stored.isEmpty) return ColorVisionType.normal;

    final lower = stored.toLowerCase();

    if (lower.contains('monokrom') || lower.contains('akromat')) {
      if (lower.contains('anomal') ||
          lower.contains('partial') ||
          lower.contains('sebagian') ||
          lower.contains('parsial')) {
        return ColorVisionType.achromatomaly;
      }
      return ColorVisionType.achromatopsia;
    }
    if (lower.contains('protan')) {
      if (lower.contains('anomal')) return ColorVisionType.protanomaly;
      return ColorVisionType.protanopia;
    }
    if (lower.contains('deuteran')) {
      if (lower.contains('anomal')) return ColorVisionType.deuteranomaly;
      return ColorVisionType.deuteranopia;
    }
    if (lower.contains('tritan')) {
      if (lower.contains('anomal')) return ColorVisionType.tritanomaly;
      return ColorVisionType.tritanopia;
    }
    if (lower.contains('normal')) {
      return ColorVisionType.normal;
    }

    return ColorVisionType.normal;
  }
}
