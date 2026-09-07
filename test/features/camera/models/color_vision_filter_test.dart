import 'package:chroma_lens/features/camera/domain/models/color_vision_filter.dart';
import 'package:chroma_lens/features/camera/domain/models/color_vision_type.dart';
import 'package:chroma_lens/features/camera/data/utils/color_vision_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorVisionFilter Model Tests', () {
    const testMatrix = <double>[
      1.0000, 0.0000, 0.0000,
      0.5089, 0.4911, 0.0000,
      0.6173, -0.6173, 1.0000,
    ];

    const testFilter = ColorVisionFilter(
      type: ColorVisionType.protanopia,
      name: 'Protanopia Assist',
      shortName: 'Protan Assist',
      subtitle: 'Red Correction Lens',
      description: 'Test description',
      matrix: testMatrix,
    );

    test('should hold correct property values', () {
      expect(testFilter.type, ColorVisionType.protanopia);
      expect(testFilter.name, 'Protanopia Assist');
      expect(testFilter.shortName, 'Protan Assist');
      expect(testFilter.subtitle, 'Red Correction Lens');
      expect(testFilter.matrix.length, 9);
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
      expect(matrix[3], closeTo(0.25445, 0.0001));
      expect(matrix[4], closeTo(0.74555, 0.0001));
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

    test('evaluateRgb clamps output strictly to [0.0, 1.0] even with extreme Tritanopia overshoot', () {
      final tritanFilter = ColorVisionFilters.tritanopia;

      final testInputs = [
        [1.0, 0.0, 0.0],
        [1.0, 0.0, 1.0],
        [0.0, 1.0, 0.0],
        [1.0, 1.0, 0.0],
        [0.9, 0.1, 0.9],
        [0.0, 0.0, 1.0],
      ];

      for (final rgb in testInputs) {
        for (final intensity in [0.5, 1.0, 1.5]) {
          final result = tritanFilter.evaluateRgb(rgb[0], rgb[1], rgb[2], intensity);
          expect(result[0], inInclusiveRange(0.0, 1.0),
              reason: 'Red channel must be clamped to [0, 1]');
          expect(result[1], inInclusiveRange(0.0, 1.0),
              reason: 'Green channel must be clamped to [0, 1]');
          expect(result[2], inInclusiveRange(0.0, 1.0),
              reason: 'Blue channel must be clamped to [0, 1]');
        }
      }
    });
  });
}
