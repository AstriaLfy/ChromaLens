import 'package:equatable/equatable.dart';

enum ColorblindType {
  protanopia,
  deuteranopia,
  tritanopia,
  monochromacy,
  normal,
}

extension ColorblindTypeExtension on ColorblindType {
  String get displayName {
    switch (this) {
      case ColorblindType.protanopia:
        return 'Protanopia (Buta Warna Merah)';
      case ColorblindType.deuteranopia:
        return 'Deuteranopia (Buta Warna Hijau)';
      case ColorblindType.tritanopia:
        return 'Tritanopia (Buta Warna Biru)';
      case ColorblindType.monochromacy:
        return 'Monokromasi / Akromatopsia (Total)';
      case ColorblindType.normal:
        return 'Penglihatan Normal';
    }
  }

  String get code {
    return name;
  }

  static ColorblindType fromCode(String code) {
    return ColorblindType.values.firstWhere(
      (type) => type.name.toLowerCase() == code.toLowerCase(),
      orElse: () => ColorblindType.normal,
    );
  }

  static ColorblindType fromManualId(String id) {
    switch (id) {
      case 'protanopia':
      case 'protanomali':
        return ColorblindType.protanopia;
      case 'deuteranopia':
      case 'deuteranomali':
        return ColorblindType.deuteranopia;
      case 'tritanopia':
      case 'tritanomali':
        return ColorblindType.tritanopia;
      case 'akromatopsia_sebagian':
      case 'akromatopsia_lengkap':
        return ColorblindType.monochromacy;
      default:
        return ColorblindType.normal;
    }
  }
}

class ColorblindConditionEntity extends Equatable {
  final ColorblindType type;
  final String description;

  const ColorblindConditionEntity({
    required this.type,
    required this.description,
  });

  @override
  List<Object?> get props => [type, description];
}
