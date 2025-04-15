import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/scanned_image_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> scannedImages = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _loadSavedImages();
  }

  void _loadSavedImages() {
    final savedImages = prefs.getStringList('saved_images') ?? [];
    setState(() {
      scannedImages = savedImages;
    });
  }

  Future<void> _saveImages() async {
    await prefs.setStringList('saved_images', scannedImages);
  }

  void _handleDelete(int index) {
    setState(() {
      scannedImages.removeAt(index);
    });
    _saveImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Edge Detection',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Colors.blueAccent],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16.0, 16, 16, 0),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Scan Receipt or Documents',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      DocumentScannerOptions documentOptions =
                          DocumentScannerOptions(
                            documentFormat: DocumentFormat.jpeg,
                            mode: ScannerMode.filter,
                            pageLimit: 100,
                            isGalleryImport: true,
                          );

                      final documentScanner = DocumentScanner(
                        options: documentOptions,
                      );
                      DocumentScanningResult result =
                          await documentScanner.scanDocument();

                      if (result.images.isNotEmpty) {
                        setState(() {
                          scannedImages.addAll(result.images);
                        });
                        _saveImages();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.document_scanner, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Scan Document',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ScannedImageList(
                images: scannedImages,
                onDelete: _handleDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
