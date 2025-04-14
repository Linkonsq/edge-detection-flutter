import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

img.Image convertCameraImage(CameraImage image) {
  if (image.format.group == ImageFormatGroup.yuv420) {
    return _convertYUV420ToImage(image);
  } else if (image.format.group == ImageFormatGroup.bgra8888) {
    return _convertBGRA8888ToImage(image);
  }
  throw Exception('Unsupported image format: ${image.format.group}');
}

img.Image _convertYUV420ToImage(CameraImage image) {
  final width = image.width;
  final height = image.height;

  final yPlane = image.planes[0].bytes;
  final uvPlane = image.planes[1].bytes;

  final imageBuffer = img.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int uvIndex = ((y ~/ 2) * (width ~/ 2)) + (x ~/ 2);
      final int yIndex = y * width + x;

      final yValue = yPlane[yIndex].toInt();
      final uValue = uvPlane[uvIndex * 2].toInt() - 128;
      final vValue = uvPlane[uvIndex * 2 + 1].toInt() - 128;

      // Convert YUV to RGB
      final r = (yValue + 1.402 * vValue).clamp(0, 255).toInt();
      final g =
          (yValue - 0.344 * uValue - 0.714 * vValue).clamp(0, 255).toInt();
      final b = (yValue + 1.772 * uValue).clamp(0, 255).toInt();

      imageBuffer.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  return imageBuffer;
}

img.Image _convertBGRA8888ToImage(CameraImage image) {
  final width = image.width;
  final height = image.height;
  final bytes = image.planes[0].bytes;

  final imageBuffer = img.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int offset = (y * width + x) * 4;

      final b = bytes[offset];
      final g = bytes[offset + 1];
      final r = bytes[offset + 2];

      imageBuffer.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  return imageBuffer;
}
