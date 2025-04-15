# Document Edge Detection Flutter App

⚠️ **Important Note**: This project is currently in an experimental state. While the app framework is fully implemented, I was unable to find a suitable pre-trained edge detection tflite model for Flutter. However, I've made significant progress in converting the HED (Holistically-Nested Edge Detection) model to TensorFlow Lite format. But I think some issues contains in the converted model.

## 📌 Project Overview
This Flutter project implements two approaches for document edge detection:
1. **Custom TFLite Model** (Main branch - Experimental)
2. **Google ML Kit** ([`google_mlkit_document_scanner`](https://github.com/Linkonsq/edge-detection-flutter/tree/google_mlkit_document_scanner) - Production-ready)

## 🛠️ Implementation Status

### Approach 1: Custom TFLite Model
- ✅ Complete Flutter app architecture
- ✅ Camera view integration
- ✅ Real-time processing pipeline
- ⚠️ Edge detection model: *Partially implemented*
  - Conversion attempted from HED Caffe to TFLite
  - See conversion process at: [hed-to-tflite repository](https://github.com/Linkonsq/hed-to-tflite)

### Approach 2: Google ML Kit
- ✅ Fully working implementation
- ✅ Native-performance document scanning
- ✅ Automatic edge detection and crop functionality
- ✅ Automatic and manual image capture

## 🚀 Setup Instructions

### For Custom TFLITE Model
```bash
git clone https://github.com/Linkonsq/edge-detection-flutter
cd edge-detection-flutter
flutter pub get
flutter run
```

### For ML Kit
```bash
git clone https://github.com/Linkonsq/edge-detection-flutter.git
cd edge-detection-flutter
git checkout google_mlkit_document_scanner
flutter pub get
flutter run
