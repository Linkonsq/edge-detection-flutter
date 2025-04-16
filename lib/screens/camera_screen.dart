import 'package:camera/camera.dart';
import 'package:edge_detection/widgets/camera_view.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Document',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Pop and refresh home screen
            Navigator.pop(context, true);
          },
        ),
      ),
      body: CameraView(
        camera: camera,
        onImageCaptured: () {
          // Return to home screen with refresh flag
          Navigator.pop(context, true);
        },
      ),
    );
  }
}
