import 'package:bloom_a1/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _recognizedText = "";
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _initializeSpeechToText();
  }

  void _initializeSpeechToText() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => debugPrint("🎤 Status: $status"),
      onError: (error) => debugPrint("⚠️ Error: $error"),
    );

    if (!available) {
      debugPrint("🚨 التعرف على الصوت غير متاح");
      _showSnackbar("🚨 التعرف على الصوت غير متاح");
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) => debugPrint("🎤 Status: $status"),
        onError: (error) => debugPrint("⚠️ Error: $error"),
      );

      if (available) {
        setState(() => _isListening = true);
        debugPrint("🎤 بدء الاستماع...");
        _showSnackbar("🎤 بدء الاستماع...");

        _speechToText.listen(
          localeId: "ar_SA",
          onResult: (result) {
            setState(() => _recognizedText = result.recognizedWords);
            debugPrint("🎙️ تم التعرف على: $_recognizedText");

            if (_recognizedText.length >= 4) {
              _handleVoiceCommand(_recognizedText);
            }
          },
        );
      } else {
        debugPrint("🚨 التعرف على الصوت غير متاح");
        _showSnackbar("🚨 التعرف على الصوت غير متاح");
      }
    }
  }

  void _handleVoiceCommand(String command) {
    command = command.trim().toLowerCase();
    debugPrint("🔍 تحليل الأمر: $command");

    bool commandRecognized = false;

    if (command.contains("تسجيل دخول") || command.contains("دخول")) {
      debugPrint("✅ تنفيذ: تسجيل دخول");
      login();
      commandRecognized = true;
    }

    if (!commandRecognized) {
      debugPrint("❌ لم يتم التعرف على الأمر! - النص المستلم: $command");
      _showSnackbar("❌ لم يتم التعرف على الأمر!");
    }

    _stopListening();
  }

  void _stopListening() {
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
      debugPrint("🛑 توقف الاستماع...");
    }
  }

  void _navigateToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
    debugPrint("🏠 الانتقال إلى الصفحة الرئيسية...");
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Image.asset(
                'assets/images/Logo_bloom.png',
                height: 274,
                width: 281,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startListening,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCDD4BA),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  elevation: 5,
                ),
                child: const Text(
                  "🎤 استماع للأوامر الصوتية",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildFormContainer(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF20272B),
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField(
              icon: Icons.phone,
              hintText: "رقم الهاتف أو البريد الإلكتروني",
              txtEditingController: emailController),
          const SizedBox(height: 15),
          _buildTextField(
              icon: Icons.lock,
              hintText: "الرقم السري",
              obscureText: true,
              txtEditingController: passwordController),
          const SizedBox(height: 25),
          _buildButton(context, text: "تسجيل الدخول"),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required IconData icon,
      required String hintText,
      required TextEditingController txtEditingController,
      bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      textAlign: TextAlign.center,
      controller: txtEditingController,
      decoration: InputDecoration(
        suffixIcon: icon == Icons.phone
            ? Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Transform.rotate(
                  angle: 4.5,
                  child: Icon(
                    icon,
                    color: Color(0xFF577363),
                    size: 30,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Icon(
                  icon,
                  color: Color(0xFF577363),
                  size: 30,
                ),
              ),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.fromLTRB(98, 18, 90, 18),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String text}) {
    return ElevatedButton(
      onPressed: () async {
        await login();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF577363),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 45),
        elevation: 5,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackbar("الرجاء إدخال البيانات المطلوبة");
      return;
    } else {
      final AuthController authController = Get.find();
      final result = await authController.login(
          emailController.text, passwordController.text);
      if (result == null) {
        _showSnackbar("تم تسجيل الدخول بنجاح");
        _navigateToHomeScreen();
      } else {
        _showSnackbar(result);
      }
    }
  }
}
