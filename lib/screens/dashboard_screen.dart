import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_plants_screen.dart';
import 'camera_screen.dart';
import 'watering_schedule_screen.dart';
import 'chatbot_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key}); //  إصلاح const

  @override
  DashboardScreenState createState() =>
      DashboardScreenState(); //  إزالة `_` من اسم الكلاس
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  //  إزالة `const` من القائمة لأنه يحتوي على عناصر غير ثابتة
  final List<Widget> _screens = [
    HomeScreen(),
    MyPlantsScreen(),
    CameraScreen(),
    WateringScheduleScreen(),
    ChatBotScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة التحكم"),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: "نباتاتي"),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: "الكاميرا"),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "الجدول"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "المساعد"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
