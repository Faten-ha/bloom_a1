import 'package:flutter/material.dart';

class PlantExploreScreen extends StatelessWidget {
  const PlantExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("استكشاف النباتات")),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
        ),
        itemCount: 6, // عدد النباتات
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            shadowColor: Colors.green.shade200,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.eco,
                    size: 60, color: Colors.green), // أيقونة بدلاً من الصورة
                const SizedBox(height: 10),
                Text('نبات ${index + 1}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}
