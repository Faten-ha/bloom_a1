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
  RxInt plantDetailsIndex = 0.obs;
  RxString currentSeason = "غير معروف".obs;

  /// Load all plants for a specific user
  Future<void> loadPlants() async {
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;
      determineCurrentSeason();

      isLoading.value = true;
      final list = await dbHelper.getPlantsByUser(userId!);

      plants.clear();
      filteredPlants.clear();

      plants.assignAll(list);
      filteredPlants.assignAll(list);

      isLoading.value = false;
      update();
    } catch (e) {
      isLoading.value = false;
      print("Error loading plants: $e");
      Get.snackbar("خطأ", "حدث خطأ أثناء تحميل النباتات",
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Filter plants by name
  void filterPlants(String query) {
    if (query.isEmpty) {
      filteredPlants.assignAll(plants);
    } else {
      final filtered = plants
          .where(
              (plant) => plant.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      filteredPlants.assignAll(filtered);
    }
    update();
  }

  /// Pick image and save it to local storage
  Future<String> saveImageToAppStorage(File image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = basename(image.path);
      final savedImage = await image.copy('${appDir.path}/$fileName');
      print("Saved image path: ${savedImage.path}");
      return savedImage.path;
    } catch (e) {
      print("Error saving image: $e");
      throw e;
    }
  }

  /// Add a new plant
  Future<void> addPlant(PlantTable plant) async {
    try {
      final save = await dbHelper.insertPlant(plant);
      if (save > 0) {
        await loadPlants(); // إعادة تحميل النباتات بعد الإضافة
        Get.snackbar("تم الحفظ", "تمت إضافة النبات بنجاح إلى نباتاتي",
            colorText: Colors.black,
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("خطأ", "لم يتم الحفظ",
            colorText: Colors.black,
            backgroundColor: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print("Error adding plant: $e");
      Get.snackbar("خطأ", "حدث خطأ أثناء إضافة النبات",
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Delete a plant
  Future<void> deletePlant(int index, int plantId) async {
    try {
      // حذف النبات من قاعدة البيانات
      await dbHelper.deletePlant(plantId);

      // حذف النبات من القوائم المحلية
      if (index >= 0 && index < filteredPlants.length) {
        plants.removeWhere((plant) => plant.id == plantId);
        filteredPlants.removeWhere((plant) => plant.id == plantId);
      }

      update(); // تحديث واجهة المستخدم
    } catch (e) {
      print("Error deleting plant: $e");
      throw e;
    }
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
