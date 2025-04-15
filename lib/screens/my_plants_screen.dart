import 'dart:io';

import 'package:bloom_a1/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../controller/plant_controller.dart';
import 'plant_details_screen.dart';
import 'watering_schedule_screen.dart';
import 'home_screen.dart';

class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  PlantController plantController = Get.find<PlantController>();

  String searchText = '';

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      _showSnackbar("التعرف على الكلام غير متاح!");
    }
  }

  void _startListening() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      _showSnackbar("جاري الاستماع...");
      _speech.listen(
        localeId: "ar_SA",
        onResult: (result) {
          setState(() => _recognizedText = result.recognizedWords);
          if (result.finalResult) {
            _handleVoiceCommand(_recognizedText);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  void _handleVoiceCommand(String command) {
    debugPrint("Recognized command: $command");
    command = command.trim().toLowerCase();
    bool commandRecognized = false;

    if (command.contains("أضف إلى جدول الري") ||
        command.contains("أضف للري") ||
        command.contains("إضافة للري") ||
        command.contains("جدول الري") ||
        command.contains("سقي النبات")) {
      _navigateToWateringSchedule();
      commandRecognized = true;
    } else if (command.contains("العودة") ||
        command.contains("الرئيسية") ||
        command.contains("ارجع") ||
        command.contains("رجوع") ||
        command.contains("الصفحة الرئيسية") ||
        command.contains("رجع")) {
      _navigateToHomeScreen();
      commandRecognized = true;
    }

    if (!commandRecognized) {
      _showSnackbar("لم يتم التعرف على الأمر!");
    }

    _stopListening();
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _navigateToWateringSchedule() {
    Get.to(() => WateringScheduleScreen());
  }

  void _navigateToHomeScreen() {
    Get.offAll(() => HomeScreen());
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showPlantDetails(int index) {
    plantController.plantDetailsIndex.value = index;
    Get.to(() => PlantDetailsScreen());
  }

  @override
  Widget build(BuildContext context) {
    plantController.loadPlants();
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA9A9A9),
              Color(0xFF577363),
              Color(0xFF063D1D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF063D1D),
                        size: 24,
                      ),
                      onPressed:
                          _navigateToHomeScreen, // العودة إلى الشاشة الرئيسية
                    ),
                    const Text(
                      "نبتاتي",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        // إضافة وظيفة البحث هنا
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  onChanged: (value) {
                    searchText = value.trim();
                    plantController.filterPlants(searchText);
                  },
                  decoration: InputDecoration(
                    hintText: '...ابحث عن نبات',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.white24,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                if (plantController.filteredPlants.isEmpty) {
                  return const Center(child: Text("لا يوجد نباتات بعد"));
                }
                if (plantController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: plantController.filteredPlants.length,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => showPlantDetails(index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF577363),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFCDD4BA),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag:
                                    'plant-image-${plantController.filteredPlants[index].name}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    width: 160,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    File(plantController
                                        .filteredPlants[index].imageUrl),
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.more_horiz,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          onSelected: (value) {
                                            if (value == 'water') {
                                              _navigateToWateringSchedule();
                                            } else if (value == 'info') {
                                              showPlantDetails(index);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'water',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.water_drop),
                                                  SizedBox(width: 8),
                                                  Text('إضافة للري'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'info',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.info_outline),
                                                  SizedBox(width: 8),
                                                  Text('تفاصيل'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF2A543C),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  plantController.currentSeason
                                                              .value ==
                                                          "الشتاء"
                                                      ? "كل ${(30 / double.parse(plantController.filteredPlants[index].winter)).round()} ايام"
                                                      : "كل ${(30 / double.parse(plantController.filteredPlants[index].summer)).round()} ايام",
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                plantController
                                                    .filteredPlants[index].name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      textDirection: TextDirection.rtl,
                                      plantController
                                          .filteredPlants[index].description!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    const SizedBox(height: 15),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2A543C),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 14),
                                          elevation: 2,
                                        ),
                                        onPressed: () {
                                          _navigateToWateringSchedule();
                                        },
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "أضف إلى جدول الري",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(width: 5),
                                            Icon(Icons.water_drop,
                                                size: 18, color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 12),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCDD4BA),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    elevation: 3,
                  ),
                  onPressed: () {
                    //add new plant
                    Get.to(() => CameraScreen());
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "إضافة نبات جديد",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.add, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // زر المايك
      floatingActionButton: FloatingActionButton(
        onPressed: _startListening,
        backgroundColor:
            const Color(0xFFCDD4BA), // نفس اللون المستخدم في المثال
        child: const Icon(Icons.mic, color: Colors.black), // أيقونة المايك
      ),
    );
  }
}
