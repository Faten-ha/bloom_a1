import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../ML/plant_classifier_controller.dart';

class CameraScreen extends StatelessWidget {
  CameraScreen({super.key});

  final PlantClassifierController controller =
      Get.put(PlantClassifierController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFA9A9A9),
            Color(0xFF577363),
            Color(0xFF063D1D),
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF063D1D),
          elevation: 0,
          title: Center(
            child: Text(
              "الكاميرا",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF063D1D),
              ),
            ),
          ),
        ),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3C1E),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.account_circle, size: 80, color: Colors.white),
                    SizedBox(height: 10),
                    Text("مرحبًا بك",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("مشاركة رابط الحساب"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("تسجيل خروج"),
                onTap: () {},
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  return controller.imageFile.value != null
                      ? Image.file(controller.imageFile.value!,
                          width: 200, height: 200, fit: BoxFit.cover)
                      : const Icon(Icons.camera_alt,
                          size: 100, color: Color(0xFF4D6B50));
                }),
                const SizedBox(height: 20),
                Obx(() => Text(controller.prediction.value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold))),
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
                      onPressed: () =>
                          controller.pickImage(ImageSource.gallery),
                      child: const Text("اختيار من المعرض"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
