import 'package:flutter_test/flutter_test.dart';

import 'package:chroma_lens/features/select_condition/domain/entities/colorblind_condition.dart';

void main() {
  group('ColorblindTypeExtension.fromManualId', () {
    test('maps manual ids to correct enum type', () {
      expect(
        ColorblindTypeExtension.fromManualId('deuteranopia'),
        ColorblindType.deuteranopia,
      );
      expect(
        ColorblindTypeExtension.fromManualId('deuteranomali'),
        ColorblindType.deuteranopia,
      );
      expect(
        ColorblindTypeExtension.fromManualId('protanomali'),
        ColorblindType.protanopia,
      );
      expect(
        ColorblindTypeExtension.fromManualId('protanopia'),
        ColorblindType.protanopia,
      );
      expect(
        ColorblindTypeExtension.fromManualId('tritanomali'),
        ColorblindType.tritanopia,
      );
      expect(
        ColorblindTypeExtension.fromManualId('tritanopia'),
        ColorblindType.tritanopia,
      );
      expect(
        ColorblindTypeExtension.fromManualId('akromatopsia_sebagian'),
        ColorblindType.monochromacy,
      );
      expect(
        ColorblindTypeExtension.fromManualId('akromatopsia_lengkap'),
        ColorblindType.monochromacy,
      );
    });

    test('falls back to normal for unknown ids', () {
      expect(
        ColorblindTypeExtension.fromManualId('unknown_type'),
        ColorblindType.normal,
      );
    });
  });
}