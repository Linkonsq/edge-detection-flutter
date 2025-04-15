import 'package:edge_detection/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class EdgeDetector {
  Interpreter? _interpreter;
  bool _isLoaded = false;
  static const int INPUT_SIZE = 256;

  Future<void> loadModel() async {
    try {
      // Load model
      _interpreter = await Interpreter.fromAsset(
        'assets/models/edge_detector.tflite',
      );

      // Set input and output shapes
      _interpreter!.allocateTensors();

      _isLoaded = true;
      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Failed to load model: $e');
      rethrow;
    }
  }

  Future<List<Offset>> detectEdges(CameraImage cameraImage) async {
    if (_interpreter == null || !_isLoaded) {
      return [];
    }

    try {
      // Convert CameraImage to img.Image
      final img.Image? image = convertCameraImage(cameraImage);
      if (image == null) {
        return [];
      }

      // Preprocess image for model input
      final processedInput = _preprocessImage(image);

      // Prepare input and output tensors
      final inputTensor = [processedInput];
      final outputShape = [1, 4, 2]; // Batch, 4 corners, x/y coordinates
      final outputTensor = List<double>.filled(
        outputShape[0] * outputShape[1] * outputShape[2],
        0.0,
      );

      // Run inference
      _interpreter!.run(inputTensor, outputTensor);

      // Process outputs
      final List<Offset> corners = [];
      for (int i = 0; i < 4; i++) {
        final x = outputTensor[i * 2] * cameraImage.width;
        final y = outputTensor[i * 2 + 1] * cameraImage.height;
        corners.add(Offset(x, y));
      }

      return corners;
    } catch (e) {
      debugPrint('Error during edge detection: $e');
      return [];
    }
  }

  List<double> _preprocessImage(img.Image image) {
    // Resize to model input size
    final resized = img.copyResize(
      image,
      width: INPUT_SIZE,
      height: INPUT_SIZE,
    );

    // Convert to grayscale if needed
    final grayscale = img.grayscale(resized);

    // Normalize pixel values to 0-1
    final inputBuffer = List<double>.filled(INPUT_SIZE * INPUT_SIZE, 0);

    for (int y = 0; y < INPUT_SIZE; y++) {
      for (int x = 0; x < INPUT_SIZE; x++) {
        final pixel = grayscale.getPixel(x, y);
        final normalizedValue = pixel.r / 255.0;
        inputBuffer[y * INPUT_SIZE + x] = normalizedValue;
      }
    }

    return inputBuffer;
  }

  void dispose() {
    if (_interpreter != null) {
      _interpreter!.close();
    }
  }
}
