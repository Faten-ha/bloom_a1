import 'dart:io';
import 'package:bloom_a1/models/plant_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../services/db_helper.dart';
import 'auth_controller.dart';

class PlantController extends GetxController {
  final plants = <PlantTable>[].obs;
  final filteredPlants = <PlantTable>[].obs;
  final isLoading = false.obs;
  final dbHelper = DBHelper();
  //plant Details index
  RxInt plantDetailsIndex = 0.obs;
  RxString currentSeason = "غير معروف".obs;

  /// Load all plants for a specific user
  Future<void> loadPlants() async {
    final authController = Get.find<AuthController>();
    final userId = authController.currentUser.value?.id;
    determineCurrentSeason();
    isLoading.value = true;
    final list = await dbHelper.getPlantsByUser(userId!);
    plants.assignAll(list);
    filteredPlants.assignAll(list); // Initialize filtered list with all plants
    isLoading.value = false;
  }

  /// Filter plants by name
  void filterPlants(String query) {
    if (query.isEmpty) {
      filteredPlants.assignAll(plants); // Reset if search is empty
    } else {
      final filtered = plants
          .where(
              (plant) => plant.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      filteredPlants.assignAll(filtered);
    }
  }

  /// Pick image and save it to local storage
  Future<String> saveImageToAppStorage(File image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = basename(image.path);
    final savedImage = await image.copy('${appDir.path}/$fileName');
    print("Saved image path: ${savedImage.path}");
    return savedImage.path;
  }

  /// Add a new plant
  Future<void> addPlant(PlantTable plant) async {
    final save = await dbHelper.insertPlant(plant);
    if (save > 0) {
      Get.snackbar("تم الحفظ", "تمت إضافة النبات بنجاح إلى نباتاتي",
          colorText: Colors.black,
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      //show error message
      Get.snackbar("خطأ", "لم يتم الحفظ",
          colorText: Colors.black,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Delete a plant by ID
  Future<void> deletePlant(int plantId, int userId) async {
    await dbHelper.deletePlant(plantId);
  }

  void determineCurrentSeason() {
    final month = DateTime.now().month;

    if (month == 11 || month == 12 || month == 1 || month == 2) {
      currentSeason.value = "الشتاء";
    } else {
      currentSeason.value = "الصيف";
    }
  }
}
