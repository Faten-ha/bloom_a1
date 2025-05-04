import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:bloom_a1/controller/auth_controller.dart';
import 'package:bloom_a1/controller/plant_controller.dart';
import 'package:bloom_a1/models/plant_table.dart';

class PlantDetailsScreen extends StatefulWidget {
  const PlantDetailsScreen({super.key});

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  final PlantController plantController = Get.find<PlantController>();
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  Future<void> _speakPlantInfo() async {
    final plantInfo =
        plantController.plants[plantController.plantDetailsIndex.value];
    if (plantInfo == null) return;

    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setPitch(1.0);

    setState(() => isSpeaking = true);
    await flutterTts.speak("اسم النبات: ${plantInfo.name}. "
        "الوصف: ${plantInfo.description}. "
        "احتياجات الضوء: ${plantInfo.light}. "
        "درجة الحرارة: ${plantInfo.temperature} درجة. "
        "السقاية: كل ${plantInfo.summer} أيام في الصيف وكل ${plantInfo.winter} أيام في الشتاء. "
        "التربة: ${plantInfo.soil}. "
        "التسميد: ${plantInfo.fertilization}. "
        "الفوائد: ${plantInfo.benefits}. "
        "تحذيرات: ${plantInfo.warning}");
  }

  Future<void> _stopSpeaking() async {
    await flutterTts.stop();
    setState(() => isSpeaking = false);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCDD4BA),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
          foregroundColor: const Color(0xFF063D1D),
          elevation: 0,
          title: const Center(
            child: Text(
              "تفاصيل النبات",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF063D1D),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isSpeaking ? Icons.volume_off : Icons.volume_up,
                color: const Color(0xFF063D1D),
              ),
              onPressed: () {
                isSpeaking ? _stopSpeaking() : _speakPlantInfo();
              },
            ),
          ],
        ),
        body: Obx(() {
          final plantInfo =
              plantController.plants[plantController.plantDetailsIndex.value];
          if (plantInfo == null) {
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
                      File(plantInfo.imageUrl),
                      width: 160,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    plantInfo.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF063D1D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPlantInfo("الوصف", plantInfo.description),
                  _buildPlantInfo("الضوء", plantInfo.light),
                  _buildPlantInfo("درجة الحرارة", "${plantInfo.temperature}°C"),
                  _buildPlantInfo(
                      "السقاية في الصيف", "كل ${plantInfo.summer} أيام"),
                  _buildPlantInfo(
                      "السقاية في الشتاء", "كل ${plantInfo.winter} أيام"),
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
}
