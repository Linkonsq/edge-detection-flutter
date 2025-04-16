import 'package:camera/camera.dart';
import 'package:edge_detection/ml/edge_detector.dart';
import 'package:edge_detection/widgets/polygon_painter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraView extends StatefulWidget {
  final CameraDescription camera;
  final VoidCallback? onImageCaptured;

  const CameraView({super.key, required this.camera, this.onImageCaptured});

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
  bool _isTakingPicture = false;

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

  Future<void> _takePicture() async {
    if (_isTakingPicture) return;

    try {
      setState(() => _isTakingPicture = true);

      // Stop image stream to take a picture
      _stopImageStream();

      // Wait for controller to be initialized
      await _initializeControllerFuture;

      // Take the picture
      final XFile photo = await _controller.takePicture();

      // Save the image to shared preferences
      await _saveImageToPrefs(photo.path);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image captured successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Call the callback if provided
        if (widget.onImageCaptured != null) {
          widget.onImageCaptured!();
        }
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Resume image stream
      _startImageStream();
      if (mounted) {
        setState(() => _isTakingPicture = false);
      }
    }
  }

  Future<void> _saveImageToPrefs(String imagePath) async {
    try {
      // Get shared preferences instance
      final prefs = await SharedPreferences.getInstance();

      // Get current saved images
      final savedImages = prefs.getStringList('saved_images') ?? [];

      // Add new image path
      savedImages.add(imagePath);

      // Save updated list
      await prefs.setStringList('saved_images', savedImages);
    } catch (e) {
      debugPrint('Error saving image to preferences: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  width: 300,
                  height: 400,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(_controller),
                        if (_detectedCorners.isNotEmpty)
                          CustomPaint(
                            painter: PolygonPainter(_detectedCorners),
                            size: Size.infinite,
                          ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _isTakingPicture ? null : _takePicture,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: Icon(
            _isTakingPicture ? Icons.hourglass_empty : Icons.camera_alt,
          ),
          label: Text(_isTakingPicture ? 'Processing...' : 'Capture'),
        ),
      ],
    );
  }
}
