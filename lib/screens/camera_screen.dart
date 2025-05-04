import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../ML/plant_classifier_controller.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  final PlantClassifierController controller =
      Get.put(PlantClassifierController());

  // إضافة متغيرات للأوامر الصوتية
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  late AnimationController _animationController;

  // قائمة بالأوامر الصوتية المتاحة
  final Map<String, List<String>> voiceCommands = {
    'take_photo': [
      'التقاط',
      'صورة',
      'كاميرا',
      'تصوير',
      'التقط صورة',
      'خذ صورة',
      'صور'
    ],
    'pick_gallery': [
      'اختيار',
      'معرض',
      'استديو',
      'اختر صورة',
      'المعرض',
      'الصور',
      'اختيار من المعرض'
    ],
    'home': [
      'رئيسية',
      'العودة',
      'ارجع',
      'رجوع',
      'رجع',
      'الصفحة الرئيسية',
      'البداية'
    ],
    'help': ['مساعدة', 'المساعدة', 'الأوامر', 'ماذا يمكنني أن أقول', 'أوامر']
  };

  @override
  void initState() {
    super.initState();

    // إعداد خاصية التعرف على الكلام
    _speech = stt.SpeechToText();
    _initializeSpeech();

    // إعداد الرسوم المتحركة
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // تهيئة خاصية التعرف على الكلام
  void _initializeSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
          _animationController.stop();
        }
      },
      onError: (errorNotification) {
        setState(() => _isListening = false);
        _animationController.stop();
        if (mounted) _showSnackbar("حدث خطأ في التعرف على الصوت");
      },
    );
  }

  // بدء الاستماع للأوامر الصوتية
  void _startListening() async {
    if (!_isListening) {
      _recognizedText = '';
      setState(() => _isListening = true);
      _showSnackbar("جاري الاستماع... انطق أمرك");

      if (await _speech.initialize()) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          _speech.listen(
            localeId: "ar_SA",
            onResult: (result) {
              if (mounted) {
                setState(() {
                  _recognizedText = result.recognizedWords;
                });
                if (result.finalResult) _handleVoiceCommand(_recognizedText);
              }
            },
            listenFor: const Duration(seconds: 10),
            pauseFor: const Duration(seconds: 3),
          );
          _animationController.repeat(reverse: true);
        }
      } else if (mounted) {
        setState(() => _isListening = false);
        _showSnackbar("التعرف على الكلام غير متاح!");
      }
    }
  }

  // توقف الاستماع للأوامر الصوتية
  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      _animationController.stop();
      setState(() => _isListening = false);
    }
  }

  // معالجة الأوامر الصوتية
  void _handleVoiceCommand(String command) {
    command = command.trim().toLowerCase();
    bool commandRecognized = false;

    if (_hasKeyword(command, voiceCommands['take_photo']!)) {
      controller.pickImage(ImageSource.camera);
      _showSnackbar("جاري التقاط صورة");
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['pick_gallery']!)) {
      controller.pickImage(ImageSource.gallery);
      _showSnackbar("اختر صورة من المعرض");
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['home']!)) {
      Get.back();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['help']!)) {
      _showHelpScreen();
      commandRecognized = true;
    }

    if (!commandRecognized) {
      _showSnackbar(
          "لم يتم التعرف على الأمر. جرب: التقاط صورة أو اختيار من المعرض");
    }

    _stopListening();
  }

  // عرض شاشة المساعدة للأوامر الصوتية
  void _showHelpScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF577363),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("الأوامر الصوتية المتاحة",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildHelpSection(
                      "التقاط صورة",
                      "قل: \"التقاط صورة\" أو \"صور\" أو \"كاميرا\"",
                      Icons.camera_alt),
                  _buildHelpSection(
                      "اختيار من المعرض",
                      "قل: \"اختيار من المعرض\" أو \"معرض\" أو \"استديو\"",
                      Icons.photo_library),
                  _buildHelpSection("العودة للصفحة الرئيسية",
                      "قل: \"الرئيسية\" أو \"العودة\" أو \"رجوع\"", Icons.home),
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
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("حسنا",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // بناء قسم في شاشة المساعدة
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
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.right),
                const SizedBox(height: 3),
                Text(description,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.right),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // التحقق من وجود كلمة في قائمة الكلمات المفتاحية
  bool _hasKeyword(String text, List<String> keywords) {
    text = text.trim().toLowerCase();
    for (var keyword in keywords) {
      if (text == keyword || text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  // عرض رسالة تنبيه
  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF204D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Color(0xFF204D32)),
              onPressed: _showHelpScreen,
              tooltip: 'مساعدة الأوامر الصوتية',
            ),
          ],
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
                  ],
                ),
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
        floatingActionButton: Stack(
          children: [
            FloatingActionButton(
              onPressed: _startListening,
              backgroundColor: _isListening
                  ? const Color(0xFF204D32)
                  : const Color(0xFFDCE3C6),
              child: Icon(Icons.mic,
                  color: _isListening ? Colors.white : Colors.black),
            ),
            if (_isListening)
              const Positioned.fill(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomSheet: _isListening
            ? Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                color: const Color(0xFF204D32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _recognizedText.isNotEmpty
                          ? "التعرف على: $_recognizedText"
                          : "جاري الاستماع...",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _stopListening,
                          child: const Text("إلغاء",
                              style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: _showHelpScreen,
                          child: const Text("مساعدة",
                              style: TextStyle(color: Colors.white)),
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
}
