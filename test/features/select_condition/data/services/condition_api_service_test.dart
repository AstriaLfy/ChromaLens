import 'package:flutter_test/flutter_test.dart';
import 'package:chroma_lens/features/select_condition/domain/entities/colorblind_condition.dart';

void main() {
  test('Condition code conversions are correct', () {
    expect(ColorblindTypeExtension.fromCode('protanopia'), ColorblindType.protanopia);
    expect(ColorblindTypeExtension.fromCode('deuteranopia'), ColorblindType.deuteranopia);
    expect(ColorblindTypeExtension.fromCode('tritanopia'), ColorblindType.tritanopia);
    expect(ColorblindTypeExtension.fromCode('monochromacy'), ColorblindType.monochromacy);
  });
}
