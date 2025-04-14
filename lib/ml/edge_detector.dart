import 'dart:typed_data';
import 'dart:ui';
import 'package:edge_detection/utils/image_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class EdgeDetector {
  late Interpreter _interpreter;
  bool _isLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('edge_detection_model.tflite');
      _isLoaded = true;
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<List<Offset>> detectEdges(dynamic image) async {
    if (!_isLoaded) return [];

    // Convert camera image to model input format
    final input = await _preprocessImage(image);

    // Run inference
    final output = List.filled(4 * 2, 0.0).reshape([4, 2]);
    _interpreter.run(input, output);

    // Convert output to screen coordinates
    return _convertToScreenCoordinates(output, image.width, image.height);
  }

  Future<Uint8List> _preprocessImage(dynamic image) async {
    // Convert to grayscale and resize to model input size
    img.Image convertedImage = convertCameraImage(image);
    img.Image resized = img.copyResize(convertedImage, width: 256, height: 256);
    img.Image gray = img.grayscale(resized);

    // Normalize pixel values
    final input = Float32List(256 * 256);
    for (int i = 0; i < 256 * 256; i++) {
      input[i] = gray.getPixel(i % 256, i ~/ 256).luminance / 255.0;
    }

    return input.buffer.asUint8List();
  }

  List<Offset> _convertToScreenCoordinates(
    List<dynamic> points,
    int width,
    int height,
  ) {
    // Convert normalized coordinates (0-1) to screen coordinates
    return points.map((point) {
      return Offset(point[0] * width, point[1] * height);
    }).toList();
  }

  void dispose() {
    _interpreter.close();
  }
}
