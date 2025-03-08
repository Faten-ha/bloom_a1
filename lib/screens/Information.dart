import 'package:flutter/material.dart';

class InformationScreen extends StatelessWidget {
  final List<Map<String, String>> plantInformation = [
    {
      'title': ':الوصف',
      'description':
          'نبات داخلي بأوراق مخططة خضراء داكنة مع خطوط فاتحة يتحرك أوراقه مع الضوء'
    },
    {'title': ':الضوء', 'description': 'يفضل الضوء غير المباشر الساطع'},
    {'title': ':درجة الحرارة', 'description': 'بين 18-25°C'},
    {
      'title': ':الري',
      'description': 'يحتاج الى 100-150 مل من الماء عند كل سقاية'
    },
    {'title': ':الرطوبة', 'description': 'يفضل الرطوبة العالية'},
    {'title': ':التربة', 'description': 'تربة خفيفة جيدة التصريف'},
    {'title': ':التسميد', 'description': 'مرة شهريا في الربيع والصيف'},
    {
      'title': ':مزاياه',
      'description': 'يضفي جمالا استوائيا للمنازل ويعزز الرطوبة'
    },
    {'title': ':تحذير', 'description': '! غير سام للحيوانات الأليفة'},
  ];

  InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFA9A9A9), // الرمادي الفاتح
              Color(0xFF577363), // الأخضر الباهت
              Color(0xFF063D1D), // الأخضر الغامق
            ],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Container(
                height: 30,
                width: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 116, 116, 116)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    const Text(
                      " البحث",
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () {},
                ),
                const SizedBox(height: 10)
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/plant1.png',
                    width: 140,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const Text(
                  'كالاتيا زيبرينا',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const Text(
                  '(CALATHEA ZEBRINA)',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF577363),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: plantInformation.map((plant) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3), // مسافة بين كل عنصر
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              plant['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            Text(
                              plant['description'] ?? '',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
