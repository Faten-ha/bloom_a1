import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _imageFile != null
              ? Image.file(_imageFile!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover) // عرض الصورة بعد التقاطها
              : const Icon(Icons.camera_alt,
                  size: 100,
                  color: Color(0xFF4D6B50)), // أيقونة إذا لم يتم التقاط صورة
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _openCamera, // استدعاء دالة فتح الكاميرا
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDCE3C6), // لون مطابق للتصميم
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
            ),
            child: const Text("التقاط صورة"),
          ),
        ],
      ),
    );
  }
}
