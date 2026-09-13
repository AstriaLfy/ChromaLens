import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';

/// Converts raw platform [CameraImage] frames into RGBA8888 buffers and
/// [ui.Image]s suitable for rendering with a [RawImage].
///
/// The camera plugin streams frames in sensor orientation. The platform
/// preview surface (CameraPreview) is already upright on Impeller backends
/// because it goes through `handlesCropAndRotation`; streamed frames are not.
/// Callers therefore should rotate the converted buffer by the same number of
/// clockwise degrees that `CameraPreview` would apply based on
/// `sensorOrientation` and the current device orientation.
abstract final class CameraFrameConverter {
  static const int rgbaBytesPerPixel = 4;

  /// Converts [image] into a tightly packed RGBA8888 buffer
  /// (`width * height * rgbaBytesPerPixel` bytes) in sensor orientation.
  ///
  /// Returns `null` when the underlying [ImageFormatGroup] is not supported.
  static Uint8List? toRgba(CameraImage image) {
    switch (image.format.group) {
      case ImageFormatGroup.yuv420:
        return _yuv420ToRgba(image);
      case ImageFormatGroup.nv21:
        return _nv21ToRgba(image);
      case ImageFormatGroup.bgra8888:
        return _bgra8888ToRgba(image);
      default:
        return null;
    }
  }

  /// Converts [image] into an upright [ui.Image], rotating the sensor-oriented
  /// buffer clockwise by [rotationDegrees] (must be a multiple of 90) before
  /// decoding.
  static Future<ui.Image?> toUiImage(
    CameraImage image, {
    int rotationDegrees = 0,
  }) async {
    final rgba = toRgba(image);
    if (rgba == null) {
      return null;
    }

    final (bytes, width, height) =
        rotateRgba(rgba, image.width, image.height, rotationDegrees);

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  /// Rotates an RGBA8888 buffer clockwise by [degreesCw] (multiple of 90).
  ///
  /// Returns the new buffer together with the rotated dimensions.
  static (Uint8List, int, int) rotateRgba(
    Uint8List rgba,
    int width,
    int height,
    int degreesCw,
  ) {
    var bytes = rgba;
    var w = width;
    var h = height;
    var remaining = degreesCw % 360;
    while (remaining >= 90) {
      (bytes, w, h) = _rotateCw90(bytes, w, h);
      remaining -= 90;
    }
    return (bytes, w, h);
  }

  /// Rotates an RGBA8888 buffer 90 degrees clockwise.
  static (Uint8List, int, int) _rotateCw90(
    Uint8List src,
    int width,
    int height,
  ) {
    final dst = Uint8List(src.length);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        // Source (row y, column x) moves to (row x, column height - 1 - y).
        final srcIndex = (y * width + x) * rgbaBytesPerPixel;
        final dstIndex = (x * height + (height - 1 - y)) * rgbaBytesPerPixel;
        for (var c = 0; c < rgbaBytesPerPixel; c++) {
          dst[dstIndex + c] = src[srcIndex + c];
        }
      }
    }
    return (dst, height, width);
  }

  /// Converts a planar or semi-planar YUV_420_888 image to RGBA8888.
  ///
  /// * Planar (3 planes, chroma pixel stride 1): U and V are read from their
  ///   dedicated planes.
  /// * Semi-planar (chroma planes with pixel stride 2): U and V are read from
  ///   plane 1 assuming a `[U, V]` interleaved layout (NV12 order), which is
  ///   the most common Android layout.
  static Uint8List _yuv420ToRgba(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final planes = image.planes;

    final yPlane = planes[0];
    final yBytes = yPlane.bytes;
    final yRowStride = yPlane.bytesPerRow;
    final yPixelStride = yPlane.bytesPerPixel ?? 1;

    int uRowStride;
    int uPixelStride;
    Uint8List uBytes;
    Uint8List vBytes;
    final bool interleaved;

    if (planes.length >= 2) {
      final uPlane = planes[1];
      uBytes = uPlane.bytes;
      uRowStride = uPlane.bytesPerRow;
      uPixelStride = uPlane.bytesPerPixel ?? 1;
      interleaved = uPixelStride > 1;
      if (planes.length >= 3) {
        vBytes = planes[2].bytes;
      } else {
        vBytes = uPlane.bytes;
      }
    } else {
      // Single-plane 420 should not occur in practice; fall back to sampling
      // the Y buffer as chroma as well so the frame still renders.
      uBytes = yBytes;
      uRowStride = yRowStride;
      uPixelStride = yPixelStride;
      vBytes = yBytes;
      interleaved = false;
    }

    final output = Uint8List(width * height * rgbaBytesPerPixel);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final yIndex = y * yRowStride + x * yPixelStride;
        if (yIndex >= yBytes.length) {
          continue;
        }
        final luma = yBytes[yIndex];

        final chromaX = x >> 1;
        final chromaY = y >> 1;
        late int u;
        late int v;
        if (interleaved) {
          final chromaIndex = chromaY * uRowStride + chromaX * 2;
          if (chromaIndex + 1 >= uBytes.length) {
            continue;
          }
          u = uBytes[chromaIndex];
          v = uBytes[chromaIndex + 1];
        } else {
          final uIndex = chromaY * uRowStride + chromaX;
          final vIndex =
              chromaY * (planes.length >= 3 ? planes[2].bytesPerRow : uRowStride) +
                  chromaX;
          if (uIndex >= uBytes.length || vIndex >= vBytes.length) {
            continue;
          }
          u = uBytes[uIndex];
          v = vBytes[vIndex];
        }

        final outputIndex = (y * width + x) * rgbaBytesPerPixel;
        output[outputIndex] = _clamp(luma + 1.402 * (v - 128));
        output[outputIndex + 1] = _clamp(
          luma - 0.344136 * (u - 128) - 0.714136 * (v - 128),
        );
        output[outputIndex + 2] = _clamp(luma + 1.772 * (u - 128));
        output[outputIndex + 3] = 0xFF;
      }
    }

    return output;
  }

  /// Converts an NV21 image (single plane: packed Y followed by interleaved
  /// VU) to RGBA8888.
  static Uint8List _nv21ToRgba(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final bytes = image.planes[0].bytes;
    final yPlaneSize = width * height;

    final output = Uint8List(width * height * rgbaBytesPerPixel);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final yIndex = y * width + x;
        if (yIndex >= yPlaneSize || yIndex >= bytes.length) {
          continue;
        }
        final luma = bytes[yIndex];

        final chromaBase =
            yPlaneSize + (y >> 1) * width + (x & ~1);
        if (chromaBase + 1 >= bytes.length) {
          continue;
        }
        // NV21 interleaves V before U.
        final v = bytes[chromaBase];
        final u = bytes[chromaBase + 1];

        final outputIndex = (y * width + x) * rgbaBytesPerPixel;
        output[outputIndex] = _clamp(luma + 1.402 * (v - 128));
        output[outputIndex + 1] = _clamp(
          luma - 0.344136 * (u - 128) - 0.714136 * (v - 128),
        );
        output[outputIndex + 2] = _clamp(luma + 1.772 * (u - 128));
        output[outputIndex + 3] = 0xFF;
      }
    }

    return output;
  }

  /// Converts a BGRA8888 image (single plane, 4 bytes per pixel) to RGBA8888
  /// by swapping the red and blue channels.
  static Uint8List _bgra8888ToRgba(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final bytes = image.planes[0].bytes;
    final rowStride = image.planes[0].bytesPerRow;

    final output = Uint8List(width * height * rgbaBytesPerPixel);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final inputIndex = y * rowStride + x * 4;
        if (inputIndex + 3 >= bytes.length) {
          continue;
        }
        final blue = bytes[inputIndex];
        final green = bytes[inputIndex + 1];
        final red = bytes[inputIndex + 2];
        final alpha = bytes[inputIndex + 3];

        final outputIndex = (y * width + x) * rgbaBytesPerPixel;
        output[outputIndex] = red;
        output[outputIndex + 1] = green;
        output[outputIndex + 2] = blue;
        output[outputIndex + 3] = alpha;
      }
    }

    return output;
  }

  static int _clamp(num value) =>
      value.round().clamp(0, 255).toInt();
}