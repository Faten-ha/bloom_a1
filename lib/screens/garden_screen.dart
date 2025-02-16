import 'package:flutter/material.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("البستان الشخصي")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: List.generate(4, (index) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Image.asset('assets/images/plant_$index.png', height: 100),
                const SizedBox(height: 5),
                Text('نباتي #$index', style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
