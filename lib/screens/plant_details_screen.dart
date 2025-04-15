import 'dart:io';

import 'package:bloom_a1/controller/auth_controller.dart';
import 'package:bloom_a1/controller/plant_controller.dart';
import 'package:bloom_a1/models/plant_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlantDetailsScreen extends StatelessWidget {
  final PlantController plantController = Get.find<PlantController>();

  PlantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFA9A9A9), // الرمادي الفاتح
            Color(0xFF577363), // الأخضر الباهت
            Color(0xFF063D1D), // الأخضر الغامق
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
              "تفاصيل النبات",
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
                onTap: () {
                  AuthController auth=Get.find();
                  auth.logout();
                },
              ),
            ],
          ),
        ),
        body: Obx(() {
          final PlantTable plantInfo =
              plantController.plants[plantController.plantDetailsIndex.value];
          if (plantInfo.isNull) {
            return const Center(child: Text("لا يوجد معلومات للنبات."));
          }
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      width: 160,
                      height: 140,
                      fit: BoxFit.cover,
                      File(plantInfo.imageUrl),
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // اسم النبات
                  Text(
                    plantInfo.name,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF063D1D)),
                  ),
                  const SizedBox(height: 16),

                  // معلومات النبات
                  _buildPlantInfo("الوصف", plantInfo.description),
                  _buildPlantInfo("الضوء", plantInfo.light),
                  _buildPlantInfo("درجة الحرارة", "${plantInfo.temperature}°C"),
                  _buildPlantInfo("السقاية في الصيف", " في الشهر ${plantInfo.summer}"),
                  _buildPlantInfo("السقاية في الشتاء", " في الشهر ${plantInfo.winter}"),
                  _buildPlantInfo("التربة", plantInfo.soil),
                  _buildPlantInfo("التسميد", plantInfo.fertilization),
                  _buildPlantInfo("المزايا", plantInfo.benefits),
                  _buildPlantInfo("تحذير", plantInfo.warning),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlantInfo(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title:",
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFCDD4BA),),
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
