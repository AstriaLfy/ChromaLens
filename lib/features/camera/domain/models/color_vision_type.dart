/// Target color vision deficiency assistance/correction types.
enum ColorVisionType {
  /// Unfiltered natural camera view
  normal,

  /// Assistance lens for Protanomaly (Mild Red deficiency)
  protanomaly,

  /// Assistance lens for Protanopia (Total Red-blindness)
  protanopia,

  /// Assistance lens for Deuteranomaly (Mild Green deficiency)
  deuteranomaly,

  /// Assistance lens for Deuteranopia (Total Green-blindness)
  deuteranopia,

  /// Assistance lens for Tritanomaly (Mild Blue deficiency)
  tritanomaly,

  /// Assistance lens for Tritanopia (Total Blue-blindness)
  tritanopia,

  /// High-contrast monochrome lens for Achromatopsia (Total Colorblindness)
  achromatopsia,

  /// Partial grayscale blend lens for Achromatomaly (Partial Colorblindness)
  achromatomaly,
}
