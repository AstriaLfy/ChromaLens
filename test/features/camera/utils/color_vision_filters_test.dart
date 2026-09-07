import 'package:chroma_lens/features/camera/domain/models/color_vision_type.dart';
import 'package:chroma_lens/features/camera/data/utils/color_vision_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorVisionFilters Repository Tests', () {
    test('availableFilters list contains 5 filters', () {
      expect(ColorVisionFilters.availableFilters.length, 5);
    });

    test('all available filters have 9-element 3x3 matrices', () {
      for (final filter in ColorVisionFilters.availableFilters) {
        expect(filter.matrix.length, 9,
            reason: '${filter.name} matrix should have exactly 9 elements (3x3).');
      }
    });

    test('matrices match the specified LMS Daltonization constants', () {
      expect(ColorVisionFilters.protanopia.matrix, equals([
        1.0000, 0.0000, 0.0000,
        0.5089, 0.4911, 0.0000,
        0.6173, -0.6173, 1.0000,
      ]));

      expect(ColorVisionFilters.deuteranopia.matrix, equals([
        1.0000, 0.0000, 0.0000,
        0.2023, 0.7977, 0.0000,
        0.5174, -0.5174, 1.0000,
      ]));

      expect(ColorVisionFilters.tritanopia.matrix, equals([
        1.0000, 0.0000, 0.0000,
        -0.0500, 1.0500, 0.0000,
        0.6500, -0.6500, 1.0000,
      ]));

      expect(ColorVisionFilters.achromatopsia.matrix, equals([
        1.25, -0.15, -0.10,
        -0.10, 1.25, -0.15,
        -0.15, -0.10, 1.25,
      ]));
    });

    test('getFilter returns corresponding filter for each ColorVisionType', () {
      expect(
        ColorVisionFilters.getFilter(ColorVisionType.normal).type,
        ColorVisionType.normal,
      );
      expect(
        ColorVisionFilters.getFilter(ColorVisionType.protanopia).type,
        ColorVisionType.protanopia,
      );
      expect(
        ColorVisionFilters.getFilter(ColorVisionType.deuteranopia).type,
        ColorVisionType.deuteranopia,
      );
      expect(
        ColorVisionFilters.getFilter(ColorVisionType.tritanopia).type,
        ColorVisionType.tritanopia,
      );
      expect(
        ColorVisionFilters.getFilter(ColorVisionType.achromatopsia).type,
        ColorVisionType.achromatopsia,
      );
    });
  });
}
