import 'package:bloom_a1/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _recognizedText = "";
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find();

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _initializeSpeechToText();
  }

  void _initializeSpeechToText() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => debugPrint("Status: $status"),
      onError: (error) => debugPrint("Error: $error"),
    );
    if (!available) _showSnackbar("التعرف على الصوت غير متاح");
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          localeId: "ar_SA",
          onResult: (result) {
            setState(() => _recognizedText = result.recognizedWords);
            if (result.finalResult) _handleVoiceCommand(_recognizedText);
          },
        );
      } else {
        _showSnackbar("التعرف على الصوت غير متاح");
      }
    }
  }

  void _handleVoiceCommand(String command) {
    command = command.trim().toLowerCase();
    if (command.contains("تسجيل دخول") || command.contains("دخول")) {
      login();
    } else if (command.contains("مساعدة") || command.contains("الأوامر")) {
      _showHelpScreen();
    } else {
      _showSnackbar("لم يتم التعرف على الأمر");
    }
    _stopListening();
  }

  void _stopListening() {
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  void _showSnackbar(String message) {
    Get.snackbar(
      'تنبيه',
      message,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackbar("الرجاء إدخال البيانات المطلوبة");
      return;
    }

    final result = await authController.login(
      emailController.text,
      passwordController.text,
    );

    if (result == null) {
      Get.offAllNamed('/home');
    } else {
      _showSnackbar(result);
    }
  }

  void _showHelpScreen() {
    // حساب ارتفاع الشاشة
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final titleSize = screenWidth * 0.055; // حجم العنوان المتجاوب
    final buttonTextSize = screenWidth * 0.045; // حجم نص الزر المتجاوب

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF577363),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(screenWidth * 0.05),
        height: screenHeight * 0.7,
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
            SizedBox(height: screenHeight * 0.02),
            Text(
              "الأوامر الصوتية المتاحة",
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.01),
            const Divider(color: Colors.white24),
            SizedBox(height: screenHeight * 0.01),
            Expanded(
              child: ListView(
                children: [
                  _buildHelpSection(
                      "تسجيل الدخول",
                      "قل: \"تسجيل دخول\" أو \"دخول\"",
                      Icons.login,
                      screenWidth),
                  _buildHelpSection("المساعدة", "قل: \"مساعدة\" أو \"الأوامر\"",
                      Icons.help, screenWidth),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF204D32),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, screenHeight * 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "حسنا",
                style: TextStyle(
                    fontSize: buttonTextSize, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(
      String title, String description, IconData icon, double screenWidth) {
    final titleSize = screenWidth * 0.04; // حجم العنوان المتجاوب
    final descSize = screenWidth * 0.035; // حجم الوصف المتجاوب
    final iconSize = screenWidth * 0.06; // حجم الأيقونة المتجاوب

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF204D32),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: descSize,
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
    final logoHeight = screenHeight * 0.22; // 22% من ارتفاع الشاشة
    final buttonTextSize = screenWidth * 0.04; // حجم النص في الأزرار
    final headerFontSize = screenWidth * 0.055; // حجم عنوان النموذج

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                Image.asset(
                  'assets/images/Logo_bloom.png',
                  height: logoHeight,
                  width: logoHeight, // جعل العرض متناسب مع الارتفاع
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: _startListening,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCDD4BA),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.012,
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    "🎤 استماع للأوامر الصوتية",
                    style: TextStyle(
                      fontSize: buttonTextSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildFormContainer(
                    screenWidth, screenHeight, headerFontSize, buttonTextSize),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer(double screenWidth, double screenHeight,
      double headerFontSize, double buttonTextSize) {
    final fieldTextSize = screenWidth * 0.038; // حجم النص في حقول الإدخال
    final iconSize = screenWidth * 0.07; // حجم الأيقونات

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFFB3BEA6),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "تسجيل الدخول",
            style: TextStyle(
              fontSize: headerFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: screenHeight * 0.025),
          _buildTextField(
              controller: emailController,
              hintText: "رقم الهاتف أو البريد الإلكتروني",
              icon: Icons.phone,
              fieldTextSize: fieldTextSize,
              iconSize: iconSize,
              screenHeight: screenHeight),
          SizedBox(height: screenHeight * 0.015),
          _buildTextField(
              controller: passwordController,
              hintText: "الرقم السري",
              icon: Icons.lock,
              obscureText: true,
              fieldTextSize: fieldTextSize,
              iconSize: iconSize,
              screenHeight: screenHeight),
          SizedBox(height: screenHeight * 0.025),
          ElevatedButton(
            onPressed: login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF577363),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.015,
                horizontal: screenWidth * 0.12,
              ),
              elevation: 5,
            ),
            child: Text(
              "تسجيل الدخول",
              style: TextStyle(
                fontSize: buttonTextSize * 1.1, // نص الزر أكبر قليلاً
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    required double fieldTextSize,
    required double iconSize,
    required double screenHeight,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: fieldTextSize),
      decoration: InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 18),
          child: Icon(
            icon,
            color: const Color(0xFF577363),
            size: iconSize,
          ),
        ),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: fieldTextSize),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.018,
          horizontal: 20,
        ),
      ),
    );
  }
}
