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

class _CameraViewState extends State<CameraView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final EdgeDetector _edgeDetector = EdgeDetector();
  List<Offset> _detectedCorners = [];
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller.initialize();

    _controller.startImageStream((CameraImage image) {
      if (_isModelLoaded) {
        _processImage(image);
      }
    });

    if (mounted) setState(() {});
  }

  Future<void> _loadModel() async {
    await _edgeDetector.loadModel();
    setState(() => _isModelLoaded = true);
  }

  Future<void> _processImage(CameraImage image) async {
    final corners = await _edgeDetector.detectEdges(image);
    setState(() => _detectedCorners = corners);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              CameraPreview(_controller),
              CustomPaint(
                painter: PolygonPainter(_detectedCorners),
                child: Container(),
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
