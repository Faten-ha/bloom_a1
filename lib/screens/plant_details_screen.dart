import 'package:flutter/material.dart';

class PlantDetailsScreen extends StatelessWidget {
  const PlantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل النبات')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/plant_1.png', height: 200),
            const SizedBox(height: 10),
            const Text('اسم النبات',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text('تفاصيل العناية بالنباتات وزيادة النمو بطريقة سليمة.'),
          ],
        ),
      ),
    );
  }
}
