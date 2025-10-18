import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(imageFile: pickedFile),
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(imageFile: pickedFile),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // --- 1. ADD THE APP BAR WITH A BACK BUTTON ---
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Placeholder preview area
          const Center(
            child: Icon(
              Icons.camera_alt_outlined,
              size: 100,
              color: Colors.white38,
            ),
          ),
          // --- 2. ADD THE GALLERY BUTTON ---
          Positioned(
            top: 20,
            left: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: _pickImageFromGallery,
              backgroundColor: Colors.white.withOpacity(0.7),
              child: const Icon(Icons.photo_library, color: Colors.black87),
            ),
          ),
          // --- 3. ADD THE CAPTURE BUTTON ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: FloatingActionButton(
                onPressed: _pickImageFromCamera,
                backgroundColor: const Color(0xFF3F7E03),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}