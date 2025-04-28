import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'const.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceChat extends StatefulWidget {
  @override
  _VoiceChatState createState() => _VoiceChatState();
}

class _VoiceChatState extends State<VoiceChat> with TickerProviderStateMixin {
  final Gemini gemini = Gemini.instance;
  FlutterTts flutterTts = FlutterTts();
  List<ChatMessage> messages = [];

  late stt.SpeechToText speechToText;
  bool _isListening = false;
  bool isGenerating = false;
  String _text = '';
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "_");

  @override
  void initState() {
    super.initState();
    speechToText = stt.SpeechToText();
    _initSpeech();

    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);
    flutterTts.setEngine("com.google.android.tts");
    _listen();
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      String question = chatMessage.text;
      final String fullPrompt = "${getBotanyPrompt(question)}\n\n$question";

      StringBuffer responseBuffer = StringBuffer();

      setState(() {
        isGenerating = true;
      });

      gemini
          .streamGenerateContent(
        fullPrompt,
        modelName: "models/gemini-1.5-flash",
      )
          .listen((event) async {
        String responsePart = event.content?.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";
        responseBuffer.write(responsePart);
        setState(() {
          if (messages.isNotEmpty && messages.first.user == geminiUser) {
            messages[0] = ChatMessage(
              user: geminiUser,
              createdAt: DateTime.now(),
              text: responseBuffer.toString(),
            );
          } else {
            messages = [
              ChatMessage(
                user: geminiUser,
                createdAt: DateTime.now(),
                text: responseBuffer.toString(),
              ),
              ...messages,
            ];
          }
        });
      }, onDone: () async {
        String finalResponse = responseBuffer.toString();
        String language = detectLanguage(finalResponse);
        await flutterTts.setLanguage(language);
        await flutterTts.speak(finalResponse);

        flutterTts.setCompletionHandler(() {
          _listen();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await speechToText.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        print('بدء الأستماع ...');
        setState(() {
          isGenerating = false;
          _isListening = true;
          _text = '';
        });

        speechToText.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
            if (result.finalResult) {
              ChatMessage chatMessage = ChatMessage(
                user: currentUser,
                createdAt: DateTime.now(),
                text: _text,
              );
              _sendMessage(chatMessage);
              setState(() => _isListening = false);
            }
          },
        );

        Future.delayed(Duration(seconds: 5), () {
          if (_text.isEmpty && _isListening) {
            speechToText.stop();
            setState(() {
              _isListening = false;
            });
          }
        });
      } else {
        print('التعرف على الصوت غير متاح');
      }
    } else {
      speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  void _stopTTS() async {
    if (isGenerating) {
      await flutterTts.stop();
      setState(() {
        isGenerating = false;
        _isListening = false;
      });
    }
  }

  Future<void> _initSpeech() async {
    bool available = await speechToText.initialize(
      onStatus: (val) => print('Speech Status: $val'),
      onError: (val) => print('Speech Error: $val'),
    );
    print('التعرف على الصوت متاح: $available');
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
              tooltip: 'رجوع',
            ),
          ],
        ),
        SizedBox(height: 60),
        Text(
          _isListening
              ? 'جاري الاستماع...'
              : (isGenerating ? 'جاري الاجابة...' : ''),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.stop, color: Colors.red),
              onPressed: isGenerating ? _stopTTS : null,
              tooltip: 'أيقاف',
              iconSize: 30,
            ),
            SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.mic, color: Colors.green),
              onPressed: !_isListening && !isGenerating ? _listen : null,
              tooltip: 'بدء الأستماع',
              iconSize: 30,
            ),
          ],
        )
      ],
    );
  }
}
