import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

img.Image? convertCameraImage(CameraImage cameraImage) {
  try {
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420ToImage(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888ToImage(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.jpeg) {
      return img.decodeJpg(cameraImage.planes[0].bytes);
    } else {
      debugPrint('Unsupported image format: ${cameraImage.format.group}');
      return null;
    }
  } catch (e) {
    debugPrint('Error converting camera image: $e');
    return null;
  }
}

img.Image _convertYUV420ToImage(CameraImage image) {
  final width = image.width;
  final height = image.height;

  final imageBuffer = img.Image(width: width, height: height);

  final yPlane = image.planes[0];
  final uPlane = image.planes[1];
  final vPlane = image.planes[2];

  final yRowStride = yPlane.bytesPerRow;
  final uvRowStride = uPlane.bytesPerRow;
  final uvPixelStride = uPlane.bytesPerPixel!;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int yIndex = y * yRowStride + x;
      // Need to reference the UVs based on the sampling patterns, not the screen coordinates
      final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

      final int yValue = yPlane.bytes[yIndex];
      final int uValue = uPlane.bytes[uvIndex];
      final int vValue = vPlane.bytes[uvIndex];

      // YUV to RGB conversion
      int r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
      int g =
          (yValue - 0.344 * (uValue - 128) - 0.714 * (vValue - 128))
              .clamp(0, 255)
              .toInt();
      int b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

      imageBuffer.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  return imageBuffer;
}

img.Image _convertBGRA8888ToImage(CameraImage image) {
  final width = image.width;
  final height = image.height;
  final bytes = image.planes[0].bytes;
  final bytesPerRow = image.planes[0].bytesPerRow;
  final bytesPerPixel = image.planes[0].bytesPerPixel!;

  final imageBuffer = img.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final pixelOffset = y * bytesPerRow + x * bytesPerPixel;

      final b = bytes[pixelOffset];
      final g = bytes[pixelOffset + 1];
      final r = bytes[pixelOffset + 2];
      final a = bytes[pixelOffset + 3];

      imageBuffer.setPixelRgba(x, y, r, g, b, a);
    }
  }

  return imageBuffer;
}
