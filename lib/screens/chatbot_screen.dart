import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'home_screen.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<String> messages = [];
  final TextEditingController _controller = TextEditingController();
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

    if (command.contains("العودة") ||
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

  void _navigateToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      messages.add("أنت: $message");
    });

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        messages.add("المساعد: ${data['response']}");
      });
    } else {
      setState(() {
        messages.add("المساعد: حدث خطأ أثناء الاتصال بالخادم.");
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // بدون AppBar
      body: Container(
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
        child: Column(
          children: [
            // إضافة padding إضافي في الجزء العلوي
            Padding(
              padding:
                  const EdgeInsets.only(top: 30), // خفض السهم والكلمة قليلًا
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // السهم على اليسار والكلمة في المنتصف
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF063D1D)), // لون السهم
                    onPressed:
                        _navigateToHomeScreen, // العودة إلى الشاشة الرئيسية
                  ),
                  const Text(
                    "مساعدة", // كلمة "مساعدة"
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF063D1D), // لون الكلمة
                    ),
                  ),
                  const SizedBox(
                      width: 48), // مساحة فارغة على اليمين لتوازن التصميم
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: messages[index].startsWith("أنت")
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: messages[index].startsWith("أنت")
                            ? Colors.white70
                            : Colors.green.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        messages[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: messages[index].startsWith("أنت")
                              ? Colors.black87
                              : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // زر الصوت
                  IconButton(
                    icon: const Icon(Icons.mic, color: Colors.green),
                    onPressed: _startListening, // بدء الاستماع للأوامر الصوتية
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "اكتب رسالتك...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // زر الإرسال
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _sendMessage(_controller.text);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
