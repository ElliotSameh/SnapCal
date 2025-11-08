import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../services/s3_service.dart'; // Your S3 service (optional)
import '../services/mock_food_detector.dart'; // Your MockFoodDetector
import 'food_detections_result.dart'; // Your models (adjust path if in models/)
import 'result_screen.dart'; // Your results screen

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final S3Service _s3Service = S3Service(); // Optional for S3 upload
  final MockFoodDetector _mockDetector = MockFoodDetector();

  bool _isProcessing = false;
  double _progress = 0.0;

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      await _processImage(pickedFile);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      await _processImage(pickedFile);
    }
  }

  Future<void> _processImage(XFile imageFile) async {
    if (!mounted) return;

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
    });

    try {
      // Optional: Upload to S3 (for persistence in demo)
      String? imageKey;
      try {
        final File file = File(imageFile.path);
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
        imageKey = await _s3Service.uploadImage(
          file: file,
          fileName: fileName,
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress * 0.5); // 50% for upload
          },
        );
        if (mounted) setState(() => _progress = 0.5); // Upload done
      } catch (e) {
        print('S3 upload skipped: $e'); // Non-critical for mock
      }

      // Mock AI detection (uses your FoodDetectionResult models)
      final result = await _mockDetector.detectFood(imageFile.path);

      if (!mounted) return;
      setState(() {
        _progress = 1.0;
        _isProcessing = false;
      });

      // Navigate to result screen with mock data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imageFile: imageFile,
            detectionResult: result, // Your FoodDetectionResult instance
            // Add onMealSaved if your ResultScreen needs it
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _progress = 0.0;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processing error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text('SnapCal AI', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Camera preview placeholder (black with icon)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, size: 120, color: Colors.white38),
                SizedBox(height: 16),
                Text(
                  'Take a photo of your meal',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
              ],
            ),
          ),
          // Gallery button (top-left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: _isProcessing ? null : _pickImageFromGallery,
              backgroundColor: _isProcessing ? Colors.grey : Colors.white,
              child: const Icon(Icons.photo_library, color: Colors.black),
            ),
          ),
          // Capture button (bottom-center)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: FloatingActionButton(
                onPressed: _isProcessing ? null : _pickImageFromCamera,
                backgroundColor: _isProcessing ? Colors.grey : const Color(0xFF3F7E03),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.circle, color: Colors.white, size: 28),
              ),
            ),
          ),
          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF3F7E03), strokeWidth: 3),
                    const SizedBox(height: 24),
                    Text(
                      _progress < 0.5 ? 'Uploading photo...' : 'AI analyzing your meal...',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.grey[800],
                        color: const Color(0xFF3F7E03),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
