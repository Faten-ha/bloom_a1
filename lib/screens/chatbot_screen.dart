import 'dart:io';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'const.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:bloom_a1/screens/voice_chat.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final Gemini gemini = Gemini.instance;
  FlutterTts flutterTts = FlutterTts(); //
  List<ChatMessage> messages = [];

  final ScrollController scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();

  late stt.SpeechToText speechToText;
  bool _isListening = false;
  bool _isGenerating = false;
  bool isTyping = false;
  String _text = '';

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Gemini");

  @override
  void initState() {
    super.initState();
    speechToText = stt.SpeechToText();
    _requestPermission();
    _initSpeech();

    flutterTts.setLanguage("ar-SA");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);
    flutterTts.setCompletionHandler(() {
      setState(() {
        _isGenerating = false;
      });
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    controller.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        await Permission.microphone.request();
      }
    } else if (Platform.isIOS) {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        await Permission.microphone.request();
      }
    }
  }

  Future<void> _initSpeech() async {
    bool available = await speechToText.initialize(
      onStatus: (val) => print('Speech Status: $val'),
      onError: (val) => print('Speech Error: $val'),
    );
    print('التعرف على الصوت متاح: $available');
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      final String fullPrompt = "${getBotanyPrompt(question)}\n\n$question";
      gemini
          .streamGenerateContent(
        fullPrompt,
        modelName: "models/gemini-1.5-flash",
      )
          .listen((event) async {
        ChatMessage? lastMessage = messages.firstOrNull;
        String response = event.content?.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

//
  void _listen() async {
    if (!_isListening) {
      bool available = await speechToText.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        print('البدء في الأستماع...');
        setState(() => _isListening = true);
        speechToText.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
            print('تم التعرف على الكلام: $_text');
            controller.text = _text;
            setState(() => _isListening = false);
          },
        );
      } else {
        print('التعرف على الصوت غير متاح');
      }
    } else {
      speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  void _readAloud(String message) async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.speak(message);
    setState(() {
      _isGenerating = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
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
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 80),
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF063D1D)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Center(
                    child: Text(
                      "مساعدة",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF063D1D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: _chatUI(),
        ),
      ),
    );
  }

  Widget _chatUI() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: messages.length,
            reverse: true,
            itemBuilder: (context, index) {
              final message = messages[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: message.user.id == currentUser.id
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        BubbleNormal(
                          text: message.text,
                          textStyle: TextStyle(color: Colors.white),
                          isSender: message.user.id == currentUser.id,
                          color: message.user.id == currentUser.id
                              ? const Color.fromARGB(255, 84, 105, 83)
                              : const Color.fromARGB(115, 130, 121, 121),
                        ),
                      ],
                    ),
                  ),
                  if (message.user.id == geminiUser.id)
                    IconButton(
                      icon: _isGenerating
                          ? const Icon(
                              Icons.volume_off,
                              color: Colors.white60,
                            )
                          : const Icon(
                              Icons.volume_up,
                              color: Colors.white60,
                            ),
                      onPressed: () {
                        if (_isGenerating) {
                          flutterTts.stop();
                          setState(() {
                            _isGenerating = false;
                          });
                        } else {
                          _readAloud(message.text);
                        }
                      },
                    ),
                ],
              );
            },
          ),
        ),
        _textFieldUI(),
      ],
    );
  }

  Widget _textFieldUI() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 108, 106, 106),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: TextStyle(color: Colors.white),
                      onChanged: (text) {
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "أكتب هنا...",
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onLongPressStart: (_) {
                      _listen();
                    },
                    onLongPressEnd: (_) {
                      speechToText.stop();
                      setState(() => _isListening = false);
                    },
                    child: IconButton(
                      icon: Icon(
                        controller.text.isEmpty ? Icons.mic : Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          _sendMessage(ChatMessage(
                            user: currentUser,
                            createdAt: DateTime.now(),
                            text: controller.text,
                          ));
                          controller.clear();
                          setState(() {});
                        }
                      },
                      constraints: BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.headset),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VoiceChat()),
              );
            },
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
