import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ML/plant_classifier_controller.dart';
import '../models/plant_model.dart';

class PlantInfoScreen extends StatelessWidget {
  final PlantClassifierController controller =
      Get.find<PlantClassifierController>();

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
              "الكاميرا :معلومات النبات",
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
        body: Obx(() {
          Plant? plant = controller.plant.value;
          File? imageFile = controller.imageFile.value;

          if (plant == null) {
            return const Center(child: Text("لم يتم تحديد النبات بعد."));
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // عرض الصورة المختارة من المستخدم
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: imageFile != null
                        ? Image.file(imageFile,
                            width: 200, height: 200, fit: BoxFit.cover)
                        : Image.asset(
                            "assets/placeholder.jpg", // صورة افتراضية في حالة عدم وجود صورة
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 12),

                  // اسم النبات
                  Text(
                    plant.name,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF063D1D)),
                  ),
                  Text(
                    "(${controller.prediction.value})",
                    style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF063D1D)),
                  ),
                  const SizedBox(height: 16),

                  // معلومات النبات
                  _buildPlantInfo("الوصف", plant.description),
                  _buildPlantInfo("الضوء", plant.light),
                  _buildPlantInfo("درجة الحرارة", "${plant.temperature}°C"),
                  _buildPlantInfo("السقاية", " في الاسبوع ${plant.watering}"),
                  _buildPlantInfo("التربة", plant.soil),
                  _buildPlantInfo("التسميد", plant.fertilization),
                  _buildPlantInfo("المزايا", plant.benefits),
                  _buildPlantInfo("تحذير", plant.warning),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  /// ويدجت فرعية لإنشاء عناصر المعلومات بشكل منظم
  Widget _buildPlantInfo(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title:",
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            content,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
