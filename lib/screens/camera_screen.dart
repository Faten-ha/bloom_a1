import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../ML/plant_classifier_controller.dart';

class CameraScreen extends StatelessWidget {
  CameraScreen({super.key});

  final PlantClassifierController controller = Get.put(PlantClassifierController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              return controller.imageFile.value != null
                  ? Image.file(controller.imageFile.value!, width: 200, height: 200, fit: BoxFit.cover)
                  : const Icon(Icons.camera_alt, size: 100, color: Color(0xFF4D6B50));
            }),
            const SizedBox(height: 20),
            Obx(() => Text(controller.prediction.value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
      
            // // Probabilities Text
            // Obx(() => Text(
            //   controller.probabilitiesText.value,
            //   textAlign: TextAlign.center,
            //   style: const TextStyle(fontSize: 14, color: Colors.black54),
            // )),
            // const SizedBox(height: 20),
      
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => controller.pickImage(ImageSource.camera),
                  child: const Text("التقاط صورة"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => controller.pickImage(ImageSource.gallery),
                  child: const Text("اختيار من المعرض"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
