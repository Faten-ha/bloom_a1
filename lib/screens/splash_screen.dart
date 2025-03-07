import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => debugPrint("🎤 Status: $status"),
      onError: (error) => debugPrint("⚠️ Error: $error"),
    );

    if (available) {
      setState(() => _isListening = true);
      debugPrint("🎤 بدء الاستماع...");

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
    }
  }

  void _handleVoiceCommand(String command) {
    if (command.trim().isEmpty) {
      debugPrint("⚠️ تم استقبال نص فارغ، يتم تجاهله...");
      return;
    }

    debugPrint("🔍 تحليل الأمر: $command");

    bool commandRecognized = false;

    if (command.contains("تسجيل دخول") || command.contains("دخول")) {
      debugPrint("✅ تنفيذ: تسجيل دخول");
      _navigateToLoginScreen();
      commandRecognized = true;
    }
    if (command.contains("إنشاء حساب") ||
        command.contains("حساب") ||
        command.contains("تسجيل جديد")) {
      debugPrint("✅ تنفيذ: إنشاء حساب");
      _navigateToSignUpScreen();
      commandRecognized = true;
    }
    if (command.contains("فتح الكاميرا")) {
      debugPrint("📷 تم فتح الكاميرا!");
      commandRecognized = true;
    }
    if (command.contains("إغلاق الكاميرا") ||
        command.contains("اغلاق الكاميرا")) {
      debugPrint("🚫 تم إغلاق الكاميرا!");
      commandRecognized = true;
    }
    if (command.contains("إضافة صورة") || command.contains("اضافة صورة")) {
      debugPrint("📸 تم إضافة صورة جديدة!");
      commandRecognized = true;
    }
    if (command.contains("الصفحة الرئيسية")) {
      debugPrint("🏠 تم الانتقال إلى الصفحة الرئيسية!");
      commandRecognized = true;
    }
    if (command.contains("مساعدة")) {
      debugPrint("❓ تم عرض المساعدة!");
      commandRecognized = true;
    }
    if (command.contains("خروج") || command.contains("إيقاف")) {
      debugPrint(" يتم إيقاف التطبيق!");
      commandRecognized = true;
    }

    _stopListening();

    if (!commandRecognized) {
      debugPrint("❌ لم يتم التعرف على الأمر! - النص المستلم: $command");
      _showSnackbar("❌ لم يتم التعرف على الأمر!");
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _navigateToLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToSignUpScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Image.asset('assets/images/Logo_bloom.png',
                height: 274, width: 281),
            const SizedBox(height: 66),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "ما من مسلم يغرس غرساً أو يزرع زرعاً \n فيأكل منه طير أو إنسان إلا كان له به صدقة",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 50),
            _buildButton(context, "إنشاء حساب", const SignUpScreen()),
            const SizedBox(height: 25),
            _buildButton(context, "تسجيل دخول", const LoginScreen()),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _startListening,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCDD4BA),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("🎤 استماع للأوامر الصوتية",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget screen) {
    return SizedBox(
      width: 262,
      height: 67,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCDD4BA),
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
