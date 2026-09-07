import '../../domain/models/color_vision_filter.dart';
import '../../domain/models/color_vision_type.dart';

/// Repository of real-time color vision correction & assistance filters (Daltonization Lens Concept).
///
/// Unlike simulation filters (which show normal vision users what colorblindness looks like),
/// these filters perform **Daltonization & Spectral Shift**: re-mapping confused color wavelengths
/// into distinct contrast channels so colorblind individuals can differentiate real-world colors
/// through their camera view—similar to Colorlite or EnChroma correction lenses.
class ColorVisionFilters {
  ColorVisionFilters._();

  /// Default Normal camera filter (Unfiltered Natural View).
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

  /// Protanopia Assistance Lens (Red Correction & Contrast Shift).
  /// Derived from Viénot-Brettel-Mollon (1999) LMS simulation & error redistribution into G and B channels.
  static const ColorVisionFilter protanopia = ColorVisionFilter(
    type: ColorVisionType.protanopia,
    name: 'Protanopia Assist',
    shortName: 'Protan Assist',
    subtitle: 'Red Correction Lens',
    description:
        'Digital correction lens for Red-Blindness (Protanopia). Enhances red contrast by projecting red details into visible blue and green channels.',
    matrix: <double>[
      1.0000, 0.0000, 0.0000,
      0.5089, 0.4911, 0.0000,
      0.6173, -0.6173, 1.0000,
    ],
  );

  /// Deuteranopia Assistance Lens (Green Correction & Contrast Shift).
  /// Derived from Viénot-Brettel-Mollon (1999) LMS simulation & error redistribution.
  static const ColorVisionFilter deuteranopia = ColorVisionFilter(
    type: ColorVisionType.deuteranopia,
    name: 'Deuteranopia Assist',
    shortName: 'Deuteran Assist',
    subtitle: 'Green Correction Lens',
    description:
        'Digital correction lens for Green-Blindness (Deuteranopia). Differentiates green and red objects by shifting green light info into red and blue channels.',
    matrix: <double>[
      1.0000, 0.0000, 0.0000,
      0.2023, 0.7977, 0.0000,
      0.5174, -0.5174, 1.0000,
    ],
  );

  /// Tritanopia Assistance Lens (Blue Correction & Contrast Shift).
  /// Derived from Viénot-Brettel-Mollon (1999) LMS simulation with normalized S-cone error scaling
  /// to prevent unnatural oversaturation while maintaining distinct blue-yellow differentiation.
  static const ColorVisionFilter tritanopia = ColorVisionFilter(
    type: ColorVisionType.tritanopia,
    name: 'Tritanopia Assist',
    shortName: 'Tritan Assist',
    subtitle: 'Blue Correction Lens',
    description:
        'Digital correction lens for Blue-Blindness (Tritanopia). Re-maps blue and yellow light details into distinguishable red and green spectrums.',
    matrix: <double>[
      1.0000, 0.0000, 0.0000,
      -0.0500, 1.0500, 0.0000,
      0.6500, -0.6500, 1.0000,
    ],
  );

  /// Achromatopsia Assistance Lens (High Contrast & Luminance Detail).
  /// Reformulated for linear space with diagonal boost and cross-channel suppression.
  static const ColorVisionFilter achromatopsia = ColorVisionFilter(
    type: ColorVisionType.achromatopsia,
    name: 'Contrast Assist',
    shortName: 'Contrast Assist',
    subtitle: 'Monochrome Detail Lens',
    description:
        'High-contrast detail lens for Total Colorblindness (Achromatopsia). Sharpens lightness and texture separation between adjacent objects.',
    matrix: <double>[
      1.25, -0.15, -0.10,
      -0.10, 1.25, -0.15,
      -0.15, -0.10, 1.25,
    ],
  );

  /// List of all available color vision assistance filters.
  static const List<ColorVisionFilter> availableFilters = [
    normal,
    protanopia,
    deuteranopia,
    tritanopia,
    achromatopsia,
  ];

  /// Retrieves filter by [ColorVisionType].
  static ColorVisionFilter getFilter(ColorVisionType type) {
    return availableFilters.firstWhere(
      (f) => f.type == type,
      orElse: () => normal,
    );
  }
}
