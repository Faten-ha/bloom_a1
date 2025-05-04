import 'package:bloom_a1/controller/auth_controller.dart';
import 'package:bloom_a1/controller/plant_controller.dart';
import 'package:bloom_a1/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _recognizedText = "";
  bool _checkingAuth = true;

  final Map<String, List<String>> voiceCommands = {
    'login': ['تسجيل دخول', 'دخول', 'سجل دخول', 'الدخول'],
    'signup': ['إنشاء حساب', 'حساب جديد', 'تسجيل', 'انشاء حساب'],
    'help': ['مساعدة', 'المساعدة', 'الأوامر', 'ماذا يمكنني أن أقول', 'أوامر']
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _initializeApp();
    Get.put(PlantController());
  }

  Future<void> _initializeApp() async {
    final authController = Get.put(AuthController());
    await authController.loadUserFromPrefs();

    if (authController.currentUser.value != null) {
      Get.offAll(() => const HomeScreen());
    } else {
      setState(() => _checkingAuth = false);
    }
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => debugPrint("🎤 Status: $status"),
      onError: (error) => debugPrint("⚠️ Error: $error"),
    );

    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        localeId: "ar_SA",
        onResult: (result) {
          if (result.finalResult) {
            setState(() => _recognizedText = result.recognizedWords);
            _handleVoiceCommand(_recognizedText);
          }
        },
      );
    }
  }

  void _handleVoiceCommand(String command) {
    command = command.trim().toLowerCase();
    if (command.isEmpty) return;

    bool commandRecognized = false;

    if (_hasKeyword(command, voiceCommands['login']!)) {
      _navigateToLoginScreen();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['signup']!)) {
      _navigateToSignUpScreen();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['help']!)) {
      _showHelpScreen();
      commandRecognized = true;
    }

    _stopListening();

    if (!commandRecognized) {
      _showSnackbar("لم يتم التعرف على الأمر. جرب: تسجيل دخول أو إنشاء حساب");
    }
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

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _navigateToLoginScreen() {
    Get.to(() => const LoginScreen());
  }

  void _navigateToSignUpScreen() {
    Get.to(() => const SignUpScreen());
  }

  void _showSnackbar(String message) {
    Get.snackbar(
      'تنبيه',
      message,
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFF204D32),
      colorText: Colors.white,
    );
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
                    "تسجيل الدخول",
                    "قل: \"تسجيل دخول\" أو \"دخول\"",
                    Icons.login,
                  ),
                  _buildHelpSection(
                    "إنشاء حساب",
                    "قل: \"إنشاء حساب\" أو \"حساب جديد\"",
                    Icons.person_add,
                  ),
                  _buildHelpSection(
                    "المساعدة",
                    "قل: \"مساعدة\" أو \"الأوامر\"",
                    Icons.help,
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

  @override
  Widget build(BuildContext context) {
    // حساب قياسات الشاشة
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // حساب أبعاد متناسبة مع الشاشة
    final logoHeight = screenHeight * 0.25; // 25% من ارتفاع الشاشة
    final buttonWidth = screenWidth * 0.7; // 70% من عرض الشاشة
    final buttonHeight = screenHeight * 0.07; // 7% من ارتفاع الشاشة
    final quoteTextSize = screenWidth * 0.045; // حجم نص مناسب للشاشة
    final buttonTextSize = screenWidth * 0.048; // حجم نص الزر مناسب للشاشة

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: screenHeight * 0.05,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelpScreen,
            tooltip: 'مساعدة الأوامر الصوتية',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF063D1D),
              Color(0xFF577363),
              Color(0xFFA9A9A9),
            ],
            stops: [0.0, 0.68, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(
                        0, -screenHeight * 0.05), // نسبة من ارتفاع الشاشة
                    child: Image.asset(
                      'assets/images/Logo_bloom.png',
                      height: logoHeight,
                      width: logoHeight, // جعل العرض متناسب مع الارتفاع
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Text(
                      "ما من مسلم يغرس غرساً أو يزرع زرعاً \n فيأكل منه طير أو إنسان إلا كان له به صدقة",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: quoteTextSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  if (_checkingAuth)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        _buildResponsiveAuthButton(
                            "إنشاء حساب",
                            () => _navigateToSignUpScreen(),
                            buttonWidth,
                            buttonHeight,
                            buttonTextSize),
                        SizedBox(height: screenHeight * 0.02),
                        _buildResponsiveAuthButton(
                            "تسجيل دخول",
                            () => _navigateToLoginScreen(),
                            buttonWidth,
                            buttonHeight,
                            buttonTextSize),
                      ],
                    ),
                  SizedBox(height: screenHeight * 0.03),
                  ElevatedButton(
                    onPressed: _isListening ? _stopListening : _startListening,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCDD4BA),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.08,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    child: Text(
                      _isListening
                          ? "🛑 إيقاف الاستماع"
                          : "🎤 استماع للأوامر الصوتية",
                      style: TextStyle(
                        fontSize: buttonTextSize * 0.9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isListening)
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                        horizontal: screenWidth * 0.05,
                      ),
                      margin: EdgeInsets.only(top: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: const Color(0xFF204D32),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _recognizedText.isNotEmpty
                                ? "التعرف على: $_recognizedText"
                                : "جاري الاستماع...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: quoteTextSize * 0.9,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
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
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // دالة جديدة لإنشاء أزرار تسجيل الدخول وإنشاء الحساب بأبعاد متناسبة
  Widget _buildResponsiveAuthButton(String text, VoidCallback onPressed,
      double width, double height, double fontSize) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCDD4BA),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
