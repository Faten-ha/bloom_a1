import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/plant_model.dart';
import '../screens/add_plant_screen.dart';

class PlantClassifierController extends GetxController {
  var imageFile = Rx<File?>(null); // Observable imageFile
  final ImagePicker picker = ImagePicker();
  Interpreter? interpreter;
  Map<int, String> labels = {};
  //plant info from json
  Map<int, Plant> plantInfo = {};
  var plant = Rx<Plant?>(null); // كائن النبات المتوقع
  var prediction = "".obs;
  var probabilitiesText = "".obs; //  VARIABLE for probability values
  static const int inputSize = 224;

  @override
  void onInit() {
    super.onInit();
    loadModel();
  }

  /// Load the TFLite model
  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset("assets/plant_model.tflite");
    await loadLabels();
    print("Model and labels loaded!");
  }

  /// Load class labels from a JSON file
  Future<void> loadLabels() async {
    String jsonString =
        await rootBundle.loadString("assets/class_mapping.json");
    String jsonInfo = await rootBundle.loadString("assets/plant_info.json");
    // تحميل معلومات النبات
    plantInfo = Plant.fromJsonMap(json.decode(jsonInfo));
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    labels = jsonMap.map((key, value) => MapEntry(value, key));
  }

  /// Preprocess the image: Resize and normalize
  Uint8List preprocessImage(File imageFile) {
    img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
    img.Image resizedImage =
        img.copyResize(image, width: inputSize, height: inputSize);

    // Convert to a Float32 input tensor
    List<int> bytes = resizedImage.getBytes();
    Float32List floatList = Float32List(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      floatList[i] = bytes[i] / 255.0; // Normalize pixels
    }

    return floatList.buffer.asUint8List();
  }

  /// Run inference and classify the plant
  Future<void> classifyImage() async {
    if (imageFile.value == null || interpreter == null || labels.isEmpty) {
      return;
    }

    Uint8List input = preprocessImage(imageFile.value!);
    var output =
        List.filled(1 * 47, 0.0).reshape([1, 47]); // Ensure it's double

    interpreter!.run(input, output);

    // Convert output to List<double>
    List<double> probabilities = output[0].cast<double>();

    // Find the index of the highest probability
    int predictedIndex =
        probabilities.indexOf(probabilities.reduce((a, b) => a > b ? a : b));

    prediction.value = labels[predictedIndex] ?? "Unknown";
// Get the top 3 highest probabilities and their indexes
    List<MapEntry<int, double>> sortedEntries = probabilities
        .asMap()
        .entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<MapEntry<int, double>> top3 = sortedEntries.take(3).toList();

    // Update UI values
    prediction.value = labels[top3.first.key] ?? "Unknown"; // Top prediction
    probabilitiesText.value = top3
        .map((entry) =>
            "${labels[entry.key] ?? 'Unknown'}: ${(entry.value * 100).toStringAsFixed(2)}%")
        .join("\n");

    /// الحصول على معلومات النبات من `plantInfo`
    if (plantInfo.containsKey(predictedIndex)) {
      plant.value = plantInfo[predictedIndex]!; // تعيين كائن النبات
      Get.to(() => AddPlantScreen()); // الانتقال إلى شاشة المعلومات
    }
  }

  // Pick an image from Camera or Gallery and call classifyImage
  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      imageFile.value = File(image.path);
      await classifyImage();
    }
  }
}
