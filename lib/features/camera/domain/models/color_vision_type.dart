/// Target color vision deficiency assistance/correction types.
enum ColorVisionType {
  /// Unfiltered natural camera view
  normal,

  /// Assistance lens for Protanopia (Red-blindness distinction)
  protanopia,

  /// Assistance lens for Deuteranopia (Green-blindness distinction)
  deuteranopia,

  /// Assistance lens for Tritanopia (Blue-blindness distinction)
  tritanopia,

  /// Contrast & detail enhancement lens for Achromatopsia (Monochromacy)
  achromatopsia,
}
