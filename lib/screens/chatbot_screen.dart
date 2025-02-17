import 'package:flutter/material.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Align(
                alignment: index % 2 == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        index % 2 == 0 ? Colors.green.shade200 : Colors.white70,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    index % 2 == 0
                        ? "مرحبًا! كيف يمكنني مساعدتك؟"
                        : "كيف أعتني بنباتاتي؟",
                    style: TextStyle(
                      fontSize: 16,
                      color: index % 2 == 0 ? Colors.white : Colors.black87,
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
              Expanded(
                child: TextField(
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
              IconButton(
                icon: const Icon(Icons.send, color: Colors.green),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
