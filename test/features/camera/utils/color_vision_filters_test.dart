import 'package:chroma_lens/features/camera/domain/models/color_vision_type.dart';
import 'package:chroma_lens/features/camera/data/utils/color_vision_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorVisionFilters Repository Tests', () {
    test('availableFilters list contains 9 filters', () {
      expect(ColorVisionFilters.availableFilters.length, 9);
    });

    test('all available filters have 9-element 3x3 matrices', () {
      for (final filter in ColorVisionFilters.availableFilters) {
        expect(filter.matrix.length, 9,
            reason: '${filter.name} matrix should have exactly 9 elements (3x3).');
      }
    });

    test('new matrices match specified values', () {
      expect(ColorVisionFilters.protanomaly.matrix, equals([
        1.0000, 0.0000, 0.0000,
        0.3297, 0.6319, 0.0384,
        0.4376, -0.5161, 1.0785,
      ]));

      expect(ColorVisionFilters.protanopia.matrix, equals([
        1.0000, 0.0000, 0.0000,
        0.4789, 0.4769, 0.0442,
        0.5973, -0.6887, 1.0914,
      ]));

      expect(ColorVisionFilters.deuteranomaly.matrix, equals([
        1.0000, 0.0000, 0.0000,
        0.1456, 0.7728, 0.0816,
        0.3619, -0.5033, 1.1414,
      ]));

      expect(ColorVisionFilters.deuteranopia.matrix, equals([
        1.0000, 0.0000, 0.0000,
        0.1628, 0.7250, 0.1122,
        0.4547, -0.6454, 1.1907,
      ]));

      expect(ColorVisionFilters.tritanomaly.matrix, equals([
        1.0000, 0.0000, 0.0000,
        -0.0414, 1.0610, -0.0196,
        -0.0748, -0.2853, 1.3601,
      ]));

      expect(ColorVisionFilters.tritanopia.matrix, equals([
        1.0000, 0.0000, 0.0000,
        -0.1005, 1.1229, -0.0225,
        -0.1836, -0.6376, 1.8212,
      ]));
    });

    test('achromatopsia filters are marked as achromat', () {
      expect(ColorVisionFilters.achromatopsia.isAchromat, true);
      expect(ColorVisionFilters.achromatomaly.isAchromat, true);
      expect(ColorVisionFilters.achromatopsia.achromatBlendRatio, 1.0);
      expect(ColorVisionFilters.achromatomaly.achromatBlendRatio, 0.55);
    });

    test('non-achromat filters have isAchromat = false', () {
      expect(ColorVisionFilters.normal.isAchromat, false);
      expect(ColorVisionFilters.protanomaly.isAchromat, false);
      expect(ColorVisionFilters.protanopia.isAchromat, false);
      expect(ColorVisionFilters.deuteranomaly.isAchromat, false);
      expect(ColorVisionFilters.deuteranopia.isAchromat, false);
      expect(ColorVisionFilters.tritanomaly.isAchromat, false);
      expect(ColorVisionFilters.tritanopia.isAchromat, false);
    });

    test('getFilter returns corresponding filter for each ColorVisionType', () {
      for (final type in ColorVisionType.values) {
        final filter = ColorVisionFilters.getFilter(type);
        expect(filter.type, type,
            reason: 'getFilter(${type.name}) should return matching type.');
      }
    });

    test('normal filter has identity matrix', () {
      expect(ColorVisionFilters.normal.matrix, equals([
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0,
      ]));
    });
  });

  group('resolveFromStoredString', () {
    test('returns normal for null or empty', () {
      expect(ColorVisionFilters.resolveFromStoredString(null), ColorVisionType.normal);
      expect(ColorVisionFilters.resolveFromStoredString(''), ColorVisionType.normal);
    });

    test('resolves select-condition displayNames', () {
      expect(
        ColorVisionFilters.resolveFromStoredString('Protanopia (Buta Warna Merah)'),
        ColorVisionType.protanopia,
      );
      expect(
        ColorVisionFilters.resolveFromStoredString('Deuteranopia (Buta Warna Hijau)'),
        ColorVisionType.deuteranopia,
      );
      expect(
        ColorVisionFilters.resolveFromStoredString('Tritanopia (Buta Warna Biru)'),
        ColorVisionType.tritanopia,
      );
      expect(
        ColorVisionFilters.resolveFromStoredString('Monokromasi / Akromatopsia (Total)'),
        ColorVisionType.achromatopsia,
      );
      expect(
        ColorVisionFilters.resolveFromStoredString('Penglihatan Normal'),
        ColorVisionType.normal,
      );
    });

    test('resolves raw server strings', () {
      expect(ColorVisionFilters.resolveFromStoredString('protanopia'), ColorVisionType.protanopia);
      expect(ColorVisionFilters.resolveFromStoredString('deuteranopia'), ColorVisionType.deuteranopia);
      expect(ColorVisionFilters.resolveFromStoredString('tritanopia'), ColorVisionType.tritanopia);
      expect(ColorVisionFilters.resolveFromStoredString('normal'), ColorVisionType.normal);
    });

    test('resolves colorblind test diagnosis strings', () {
      expect(ColorVisionFilters.resolveFromStoredString('Deuteranomaly'), ColorVisionType.deuteranomaly);
      expect(ColorVisionFilters.resolveFromStoredString('Protanomaly'), ColorVisionType.protanomaly);
      expect(ColorVisionFilters.resolveFromStoredString('Monokromasi'), ColorVisionType.achromatopsia);
    });

    test('resolves anomaly types with anomali keyword', () {
      expect(ColorVisionFilters.resolveFromStoredString('Protanomali'), ColorVisionType.protanomaly);
      expect(ColorVisionFilters.resolveFromStoredString('Deuteranomali'), ColorVisionType.deuteranomaly);
      expect(ColorVisionFilters.resolveFromStoredString('Tritanomali'), ColorVisionType.tritanomaly);
    });

    test('resolves manual akromatopsia ids', () {
      expect(ColorVisionFilters.resolveFromStoredString('akromatopsia_sebagian'), ColorVisionType.achromatomaly);
      expect(ColorVisionFilters.resolveFromStoredString('akromatopsia_lengkap'), ColorVisionType.achromatopsia);
    });

    test('returns normal for unrecognized strings', () {
      expect(ColorVisionFilters.resolveFromStoredString('unknown_type'), ColorVisionType.normal);
    });
  });
}
