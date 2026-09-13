import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:chroma_lens/features/camera/data/utils/camera_frame_converter.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a synthetic YUV_420_888 (planar) frame.
CameraImage _yuv420Image({
  required int width,
  required int height,
  required Uint8List y,
  required Uint8List u,
  required Uint8List v,
}) {
  return CameraImage.fromPlatformInterface(
    CameraImageData(
      format: const CameraImageFormat(ImageFormatGroup.yuv420, raw: 35),
      width: width,
      height: height,
      planes: [
        CameraImagePlane(bytes: y, bytesPerRow: width, bytesPerPixel: 1),
        CameraImagePlane(
          bytes: u,
          bytesPerRow: (width / 2).ceil(),
          bytesPerPixel: 1,
        ),
        CameraImagePlane(
          bytes: v,
          bytesPerRow: (width / 2).ceil(),
          bytesPerPixel: 1,
        ),
      ],
    ),
  );
}

void main() {
  group('CameraFrameConverter YUV_420_888', () {
    test('plain grey frame yields grey RGBA output', () {
      const width = 4;
      const height = 4;
      // Y=128, U=128, V=128 => R=G=B=128 for every pixel.
      final y = Uint8List.fromList(List.filled(width * height, 128));
      final uv = Uint8List.fromList(
        List.filled((width ~/ 2) * (height ~/ 2), 128),
      );
      final image =
          _yuv420Image(width: width, height: height, y: y, u: uv, v: uv);

      final rgba = CameraFrameConverter.toRgba(image)!;

      expect(rgba.length, width * height * 4);
      expect(rgba[0], 128);
      expect(rgba[1], 128);
      expect(rgba[2], 128);
      expect(rgba[3], 255);
    });

    test('red chroma produces red-ish pixel (BT.601)', () {
      const width = 8;
      const height = 8;
      // Pure red: Y=76, U=84, V=255 in BT.601 scaling.
      final y = Uint8List.fromList(List.filled(width * height, 76));
      final u = Uint8List.fromList(
        List.filled((width ~/ 2) * (height ~/ 2), 84),
      );
      final v = Uint8List.fromList(
        List.filled((width ~/ 2) * (height ~/ 2), 255),
      );
      final image =
          _yuv420Image(width: width, height: height, y: y, u: u, v: v);

      final rgba = CameraFrameConverter.toRgba(image)!;

      // Red channel strongly dominant over blue.
      expect(rgba[0], greaterThan(200));
      expect(rgba[2], lessThan(100));
      expect(rgba[3], 255);
    });

    test('rowStride padding is respected (bytesPerPixel=1 planar)', () {
      // width 4 -> u/v rows are 2 wide, but create rows padded to 4 bytes.
      const width = 4;
      const height = 4;
      final y = Uint8List.fromList(List.filled(width * height, 128));
      final padded = Uint8List.fromList(List.filled(4 * 2, 0));
      // Row 0 chroma = [128, 128, pad, pad]; Row 1 likewise.
      for (var row = 0; row < 2; row++) {
        padded[row * 4] = 128;
        padded[row * 4 + 1] = 128;
      }
      const rowStridePadded = 4;
      final image = _yuv420Image(
        width: width,
        height: height,
        y: y,
        u: padded,
        v: padded,
      );
      // Override the padded planes with explicit stride.
      final explicitImage = CameraImage.fromPlatformInterface(
        CameraImageData(
          format: const CameraImageFormat(ImageFormatGroup.yuv420, raw: 35),
          width: width,
          height: height,
          planes: [
            CameraImagePlane(bytes: y, bytesPerRow: width, bytesPerPixel: 1),
            CameraImagePlane(
              bytes: padded,
              bytesPerRow: rowStridePadded, // padded stride
              bytesPerPixel: 1,
            ),
            CameraImagePlane(
              bytes: padded,
              bytesPerRow: rowStridePadded,
              bytesPerPixel: 1,
            ),
          ],
        ),
      );
      expect(image, isNotNull);

      final rgba = CameraFrameConverter.toRgba(explicitImage)!;

      expect(rgba[0], 128);
      expect(rgba[1], 128);
      expect(rgba[2], 128);
    });
  });

  group('CameraFrameConverter NV21', () {
    test('single-plane NV21 (Y then VU) converts correctly', () {
      const width = 4;
      const height = 4;
      final buffer = Uint8List(
        width * height + width * height ~/ 2,
      );
      // Luma plane.
      for (var i = 0; i < width * height; i++) {
        buffer[i] = 128;
      }
      // Chroma interleaved VU: V=255, U=84 gives a predominantly red pixel.
      final chromaStart = width * height;
      for (var i = chromaStart; i < buffer.length; i += 2) {
        buffer[i] = 255; // V
        buffer[i + 1] = 84; // U
      }
      final image = CameraImage.fromPlatformInterface(
        CameraImageData(
          format: const CameraImageFormat(ImageFormatGroup.nv21, raw: 17),
          width: width,
          height: height,
          planes: [
            CameraImagePlane(
              bytes: buffer,
              bytesPerRow: width,
              bytesPerPixel: 1,
            ),
          ],
        ),
      );

      final rgba = CameraFrameConverter.toRgba(image)!;

      expect(rgba[0], greaterThan(200));
      expect(rgba[2], lessThan(100));
      expect(rgba[3], 255);
    });
  });

  group('CameraFrameConverter BGRA8888', () {
    test('swaps red and blue channels', () {
      const width = 2;
      const height = 1;
      // Pixels are BGRA: (B=32, G=64, R=255) and (B=200, G=0, R=10).
      final bgra = Uint8List.fromList([
        32, 64, 255, 255,
        200, 0, 10, 255,
      ]);
      final image = CameraImage.fromPlatformInterface(
        CameraImageData(
          format: const CameraImageFormat(ImageFormatGroup.bgra8888, raw: 0),
          width: width,
          height: height,
          planes: [
            CameraImagePlane(bytes: bgra, bytesPerRow: width * 4),
          ],
        ),
      );

      final rgba = CameraFrameConverter.toRgba(image)!;

      expect([rgba[0], rgba[1], rgba[2], rgba[3]], [255, 64, 32, 255]);
      expect([rgba[4], rgba[5], rgba[6], rgba[7]], [10, 0, 200, 255]);
    });
  });

  group('CameraFrameConverter rotation', () {
    test('90 degrees clockwise rotates and swaps dimensions', () {
      // 2x1 RGBA row: [red, green] with red on the left.
      final rgba = Uint8List.fromList([255, 0, 0, 255, 0, 255, 0, 255]);

      final (rotated, width, height) =
          CameraFrameConverter.rotateRgba(rgba, 2, 1, 90);

      expect(width, 1);
      expect(height, 2);
      // Rotating clockwise puts the left pixel at the top.
      expect([rotated[0], rotated[1], rotated[2]], [255, 0, 0]);
      expect([rotated[4], rotated[5], rotated[6]], [0, 255, 0]);
    });

    test('180 degrees reverses the row order', () {
      final rgba = Uint8List.fromList([255, 0, 0, 255, 0, 255, 0, 255]);

      final (rotated, width, height) =
          CameraFrameConverter.rotateRgba(rgba, 2, 1, 180);

      expect(width, 2);
      expect(height, 1);
      expect([rotated[0], rotated[1], rotated[2]], [0, 255, 0]);
      expect([rotated[4], rotated[5], rotated[6]], [255, 0, 0]);
    });

    test('360 degrees is identity', () {
      final rgba = Uint8List.fromList([255, 0, 0, 255, 0, 255, 0, 255]);

      final (rotated, width, height) =
          CameraFrameConverter.rotateRgba(rgba, 2, 1, 360);

      expect(width, 2);
      expect(height, 1);
      expect(rotated, rgba);
    });

    test('repeated 90 degree rotations equal 180 degrees', () {
      final rgba = Uint8List.fromList([255, 0, 0, 255, 0, 255, 0, 255]);
      final (once, w1, h1) =
          CameraFrameConverter.rotateRgba(rgba, 2, 1, 90);
      final (twice, w2, h2) =
          CameraFrameConverter.rotateRgba(once, w1, h1, 90);

      final (direct, directWidth, directHeight) =
          CameraFrameConverter.rotateRgba(rgba, 2, 1, 180);

      expect(twice, direct);
      expect(w2, 2);
      expect(h2, 1);
      expect(directWidth, 2);
      expect(directHeight, 1);
    });
  });
}