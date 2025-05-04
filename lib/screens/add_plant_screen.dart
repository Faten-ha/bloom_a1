import 'dart:io';
import 'package:bloom_a1/controller/plant_controller.dart';
import 'package:bloom_a1/models/plant_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../ML/plant_classifier_controller.dart';
import '../controller/auth_controller.dart';
import '../models/plant_model.dart';
import 'my_plants_screen.dart';

class AddPlantScreen extends StatefulWidget {
  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  late final PlantClassifierController controller;
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  bool isSpeaking = false;

  final Map<String, List<String>> voiceCommands = {
    'read_info': [
      'اقرأ المعلومات',
      'اقرأ لي',
      'المعلومات',
      'اطلعني على المعلومات',
      'تفاصيل النبات'
    ],
    'stop_reading': ['توقف', 'ايقاف', 'اسكت', 'كفى', 'اوقف القراءة'],
    'save_plant': [
      'احفظ النبتة',
      'أضف النبتة',
      'إضافة النبتة',
      'حفظ',
      'أضف إلى نباتاتي',
      'احفظ إلى نباتاتي'
    ],
    'back': ['رجوع', 'عودة', 'ارجع', 'العودة', 'الخلف', 'الصفحة السابقة'],
    'help': [
      'مساعدة',
      'المساعدة',
      'الأوامر',
      'ماذا يمكنني أن أقول',
      'أوامر الصوت'
    ]
  };

  @override
  void initState() {
    super.initState();
    controller = Get.put(PlantClassifierController());
    _initializeSpeech();
  }

  @override
  void dispose() {
    flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  void _initializeSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        setState(() => _isListening = false);
        if (mounted) {
          _showSnackbar("حدث خطأ في التعرف على الصوت");
        }
      },
    );
  }

  void _startListening() async {
    if (!_isListening) {
      _recognizedText = '';
      setState(() => _isListening = true);
      _showSnackbar("جاري الاستماع... انطق أمرك");

      if (await _speech.initialize()) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          _speech.listen(
            localeId: "ar-SA",
            onResult: (result) {
              if (mounted) {
                setState(() {
                  _recognizedText = result.recognizedWords;
                });
                if (result.finalResult) {
                  _handleVoiceCommand(_recognizedText);
                }
              }
            },
            listenFor: const Duration(seconds: 10),
            pauseFor: const Duration(seconds: 3),
          );
        }
      } else if (mounted) {
        setState(() => _isListening = false);
        _showSnackbar("التعرف على الكلام غير متاح!");
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _handleVoiceCommand(String command) {
    command = command.trim().toLowerCase();
    bool commandRecognized = false;

    if (_hasKeyword(command, voiceCommands['read_info']!)) {
      _speakPlantInfo();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['stop_reading']!)) {
      _stopSpeaking();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['save_plant']!)) {
      _savePlantToMyPlants();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['back']!)) {
      Get.delete<PlantClassifierController>();
      Get.back();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['help']!)) {
      _showHelpScreen();
      commandRecognized = true;
    }

    if (!commandRecognized) {
      _showSnackbar(
          "لم يتم التعرف على الأمر. جرب: 'اقرأ المعلومات' أو 'احفظ النبتة'");
    }

    _stopListening();
  }

  Future<void> _speakPlantInfo() async {
    final Plant? plant = controller.plant.value;
    if (plant == null) return;

    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setPitch(1.0);

    setState(() => isSpeaking = true);
    await flutterTts.speak("اسم النبات: ${plant.name}. "
        "الوصف: ${plant.description}. "
        "احتياجات الضوء: ${plant.light}. "
        "درجة الحرارة: ${plant.temperature} درجة. "
        "السقاية: كل ${plant.summer} أيام في الصيف وكل ${plant.winter} أيام في الشتاء. "
        "التربة: ${plant.soil}. "
        "التسميد: ${plant.fertilization}. "
        "الفوائد: ${plant.benefits}. "
        "تحذيرات: ${plant.warning}");
  }

  Future<void> _stopSpeaking() async {
    await flutterTts.stop();
    setState(() => isSpeaking = false);
    _showSnackbar("تم إيقاف القراءة");
  }

  Future<void> _savePlantToMyPlants() async {
    final Plant? plant = controller.plant.value;
    final File? imageFile = controller.imageFile.value;

    if (plant == null || imageFile == null) {
      _showSnackbar("لم يتم تحديد نبات أو صورة");
      return;
    }

    PlantController plantController = Get.find<PlantController>();
    final imagePath = await plantController.saveImageToAppStorage(imageFile);

    final authController = Get.find<AuthController>();
    final userId = authController.currentUser.value?.id;

    if (userId == null) {
      _showSnackbar("الرجاء تسجيل الدخول أولًا");
      return;
    }

    final newPlant = PlantTable(
      name: plant.name,
      description: plant.description,
      light: plant.light,
      temperature: plant.temperature,
      summer: plant.summer,
      winter: plant.winter,
      soil: plant.soil,
      fertilization: plant.fertilization,
      benefits: plant.benefits,
      warning: plant.warning,
      userId: userId,
      imageUrl: imagePath,
    );

    try {
      await plantController.addPlant(newPlant);
      _showSnackbar("تمت إضافة النبتة إلى قائمتك بنجاح");
      await flutterTts.speak("تم حفظ النبتة بنجاح في قائمتك");
    } catch (e) {
      _showSnackbar("حدث خطأ أثناء حفظ النبتة");
    }
  }

  void _showHelpScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF577363),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(128),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "الأوامر الصوتية المتاحة",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildHelpSection(
                    "قراءة المعلومات",
                    "قل: \"اقرأ المعلومات\" أو \"اطلعني على التفاصيل\"",
                    Icons.volume_up,
                  ),
                  _buildHelpSection(
                    "إيقاف القراءة",
                    "قل: \"توقف\" أو \"اوقف القراءة\"",
                    Icons.volume_off,
                  ),
                  _buildHelpSection(
                    "حفظ النبتة",
                    "قل: \"احفظ النبتة\" أو \"أضف إلى نباتاتي\"",
                    Icons.save,
                  ),
                  _buildHelpSection(
                    "العودة للخلف",
                    "قل: \"رجوع\" أو \"عودة\" أو \"ارجع\"",
                    Icons.arrow_back,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF204D32),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "حسنا",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF204D32),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasKeyword(String text, List<String> keywords) {
    text = text.trim().toLowerCase();
    for (var keyword in keywords) {
      if (text == keyword || text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF204D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF204D32)),
            onPressed: () {
              Get.delete<PlantClassifierController>();
              Get.back();
            },
          ),
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
          actions: [
            IconButton(
              icon: Icon(Icons.mic,
                  color: _isListening ? Colors.green : Color(0xFF063D1D)),
              onPressed: _isListening ? _stopListening : _startListening,
            ),
            IconButton(
              icon: Icon(Icons.help_outline, color: Color(0xFF063D1D)),
              onPressed: _showHelpScreen,
            ),
          ],
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: imageFile != null
                        ? Image.file(imageFile,
                            width: 200, height: 200, fit: BoxFit.cover)
                        : Image.asset(
                            "assets/placeholder.jpg",
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 12),
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
                  // زر السماعة في المنتصف
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: isSpeaking ? _stopSpeaking : _speakPlantInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSpeaking ? Colors.red : Color(0xFF204D32),
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                      ),
                      child: Icon(
                        isSpeaking ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  _buildPlantInfo("الوصف", plant.description),
                  _buildPlantInfo("الضوء", plant.light),
                  _buildPlantInfo("درجة الحرارة", "${plant.temperature}°C"),
                  _buildPlantInfo(
                      "السقاية في الصيف", "كل ${plant.summer} أيام"),
                  _buildPlantInfo(
                      "السقاية في الشتاء", "كل ${plant.winter} أيام"),
                  _buildPlantInfo("التربة", plant.soil),
                  _buildPlantInfo("التسميد", plant.fertilization),
                  _buildPlantInfo("المزايا", plant.benefits),
                  _buildPlantInfo("تحذير", plant.warning),
                  const SizedBox(height: 20),
                  _buildButton(context, text: "حفظ الى نباتاتي"),
                ],
              ),
            ),
          );
        }),
        bottomSheet: _isListening
            ? Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                color: const Color(0xFF204D32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _recognizedText.isNotEmpty
                          ? "التعرف على: $_recognizedText"
                          : "جاري الاستماع...",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _stopListening,
                          child: const Text(
                            "إلغاء",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: _showHelpScreen,
                          child: const Text(
                            "مساعدة",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String text}) {
    return ElevatedButton(
      onPressed: _savePlantToMyPlants,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCDD4BA),
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        elevation: 3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.save, size: 18, color: Colors.black),
          SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
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
