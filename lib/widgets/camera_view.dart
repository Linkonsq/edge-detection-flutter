import 'package:camera/camera.dart';
import 'package:edge_detection/ml/edge_detector.dart';
import 'package:edge_detection/widgets/polygon_painter.dart';
import 'package:flutter/material.dart';

class CameraView extends StatefulWidget {
  final CameraDescription camera;

  const CameraView({super.key, required this.camera});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final EdgeDetector _edgeDetector = EdgeDetector();
  List<Offset> _detectedCorners = [];
  bool _isModelLoaded = false;
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _loadModel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopImageStream();
    _controller.dispose();
    _edgeDetector.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize the camera
    if (!_controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopImageStream();
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _controller = CameraController(
        widget.camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {});
        _startImageStream();
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _startImageStream() {
    _controller.startImageStream((CameraImage image) {
      if (_isModelLoaded && !_isProcessingImage) {
        _processImage(image);
      }
    });
  }

  void _stopImageStream() {
    if (_controller.value.isStreamingImages) {
      _controller.stopImageStream();
    }
  }

  Future<void> _loadModel() async {
    try {
      await _edgeDetector.loadModel();
      if (mounted) {
        setState(() => _isModelLoaded = true);
      }
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessingImage) return;

    _isProcessingImage = true;
    try {
      final corners = await _edgeDetector.detectEdges(image);
      if (mounted) {
        setState(() => _detectedCorners = corners);
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessingImage = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_controller),
              if (_detectedCorners.isNotEmpty)
                CustomPaint(
                  painter: PolygonPainter(_detectedCorners),
                  size: Size.infinite,
                ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
