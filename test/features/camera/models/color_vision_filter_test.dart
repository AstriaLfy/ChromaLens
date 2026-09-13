import 'package:chroma_lens/features/camera/domain/models/color_vision_filter.dart';
import 'package:chroma_lens/features/camera/domain/models/color_vision_type.dart';
import 'package:chroma_lens/features/camera/data/utils/color_vision_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorVisionFilter Model Tests', () {
    const testMatrix = <double>[
      1.0000, 0.0000, 0.0000,
      0.4789, 0.4769, 0.0442,
      0.5973, -0.6887, 1.0914,
    ];

    const testFilter = ColorVisionFilter(
      type: ColorVisionType.protanopia,
      name: 'Protanopia Assist',
      shortName: 'Protanopia',
      subtitle: 'Red Correction Lens',
      description: 'Test description',
      matrix: testMatrix,
    );

    test('should hold correct property values', () {
      expect(testFilter.type, ColorVisionType.protanopia);
      expect(testFilter.name, 'Protanopia Assist');
      expect(testFilter.shortName, 'Protanopia');
      expect(testFilter.subtitle, 'Red Correction Lens');
      expect(testFilter.matrix.length, 9);
      expect(testFilter.isAchromat, false);
      expect(testFilter.achromatBlendRatio, 1.0);
    });

    test('getMatrixWithIntensity at 1.0 returns target matrix', () {
      final matrix = testFilter.getMatrixWithIntensity(1.0);
      expect(matrix, equals(testMatrix));
    });

    test('getMatrixWithIntensity at 0.0 returns Identity Matrix', () {
      final matrix = testFilter.getMatrixWithIntensity(0.0);
      expect(matrix, equals(ColorVisionFilter.identityMatrix));
      expect(matrix, equals([
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0,
      ]));
    });

    test('getMatrixWithIntensity at 0.5 returns interpolated midpoint values', () {
      final matrix = testFilter.getMatrixWithIntensity(0.5);
      // identity[3]=0.0, matrix[3]=0.4789 → 0.23945
      expect(matrix[3], closeTo(0.23945, 0.0001));
      // identity[4]=1.0, matrix[4]=0.4769 → 0.73845
      expect(matrix[4], closeTo(0.73845, 0.0001));
      expect(matrix[0], closeTo(1.0, 0.0001));
    });

    test('getMatrixWithIntensity clamps values out of [0.0, 1.0] bounds', () {
      final underbound = testFilter.getMatrixWithIntensity(-0.5);
      expect(underbound, equals(ColorVisionFilter.identityMatrix));

      final overbound = testFilter.getMatrixWithIntensity(1.5);
      expect(overbound, equals(testMatrix));
    });

    test('evaluateRgb at intensity=0% returns identical color (identity transform)', () {
      final colorsToTest = [
        [0.0, 0.0, 0.0],
        [1.0, 1.0, 1.0],
        [1.0, 0.0, 0.0],
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 1.0],
        [0.8, 0.4, 0.2],
        [0.2, 0.7, 0.9],
      ];

      for (final rgb in colorsToTest) {
        final result = testFilter.evaluateRgb(rgb[0], rgb[1], rgb[2], 0.0);
        expect(result[0], closeTo(rgb[0], 0.0001));
        expect(result[1], closeTo(rgb[1], 0.0001));
        expect(result[2], closeTo(rgb[2], 0.0001));
      }
    });

    test('evaluateRgb clamps output strictly to [0.0, 1.0] for all types', () {
      final filtersToTest = [
        ColorVisionFilters.protanomaly,
        ColorVisionFilters.protanopia,
        ColorVisionFilters.deuteranomaly,
        ColorVisionFilters.deuteranopia,
        ColorVisionFilters.tritanomaly,
        ColorVisionFilters.tritanopia,
        ColorVisionFilters.achromatopsia,
        ColorVisionFilters.achromatomaly,
      ];

      final testInputs = [
        [1.0, 0.0, 0.0],
        [1.0, 0.0, 1.0],
        [0.0, 1.0, 0.0],
        [1.0, 1.0, 0.0],
        [0.9, 0.1, 0.9],
        [0.0, 0.0, 1.0],
      ];

      for (final filter in filtersToTest) {
        for (final rgb in testInputs) {
          for (final intensity in [0.5, 1.0]) {
            final result = filter.evaluateRgb(rgb[0], rgb[1], rgb[2], intensity);
            expect(result[0], inInclusiveRange(0.0, 1.0),
                reason: '${filter.name} Red channel must be clamped');
            expect(result[1], inInclusiveRange(0.0, 1.0),
                reason: '${filter.name} Green channel must be clamped');
            expect(result[2], inInclusiveRange(0.0, 1.0),
                reason: '${filter.name} Blue channel must be clamped');
          }
        }
      }
    });

    test('identity matrix at intensity=0 produces no change for all filter types', () {
      for (final filter in ColorVisionFilters.availableFilters) {
        final result = filter.evaluateRgb(0.5, 0.3, 0.7, 0.0);
        expect(result[0], closeTo(0.5, 0.001),
            reason: '${filter.name} Red unchanged at intensity=0');
        expect(result[1], closeTo(0.3, 0.001),
            reason: '${filter.name} Green unchanged at intensity=0');
        expect(result[2], closeTo(0.7, 0.001),
            reason: '${filter.name} Blue unchanged at intensity=0');
      }
    });

    test('achromatopsia at full intensity produces near-grayscale output', () {
      final result = ColorVisionFilters.achromatopsia.evaluateRgb(
        1.0, 0.0, 0.0, 1.0,
      );
      // All channels should be very close to each other (grayscale)
      expect(result[0], closeTo(result[1], 0.01),
          reason: 'R and G should be nearly equal (grayscale)');
      expect(result[1], closeTo(result[2], 0.01),
          reason: 'G and B should be nearly equal (grayscale)');
    });

    test('achromatomaly at full intensity produces partial grayscale blend', () {
      final result = ColorVisionFilters.achromatomaly.evaluateRgb(
        1.0, 0.0, 0.0, 1.0,
      );
      // Output should be between original and grayscale
      expect(result[0], inInclusiveRange(0.0, 1.0));
      expect(result[1], inInclusiveRange(0.0, 1.0));
      expect(result[2], inInclusiveRange(0.0, 1.0));
      // Red channel should be less than 1.0 (blended toward grayscale)
      expect(result[0], lessThan(1.0));
    });

    test('getColorFilterWithIntensity returns valid ColorFilter', () {
      for (final filter in ColorVisionFilters.availableFilters) {
        final colorFilter = filter.getColorFilterWithIntensity(0.5);
        expect(colorFilter, isNotNull);
      }
    });
  });
}
