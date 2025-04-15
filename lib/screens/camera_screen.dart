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
      ),
      body: CameraView(camera: camera),
    );
  }
}
