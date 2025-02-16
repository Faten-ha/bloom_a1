import 'package:flutter/material.dart';
import 'my_plants_screen.dart';
import 'camera_screen.dart';
import 'watering_schedule_screen.dart';
import 'settings_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyPlantsScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WateringScheduleScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF063D1D)),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                "الصفحة الرئيسية",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF063D1D),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Color(0xFF063D1D)),
                  onPressed: () {
                    // فتح قائمة الإعدادات داخل الصفحة الرئيسية كـ Dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            color: const Color(0xFF577363),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomeScreen()),
                                    );
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF577363),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'تسجيل خروج',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
              centerTitle: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    "مرحبًا",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF063D1D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildMainButton("اكتشف نبتتك", "assets/images/plant1.png"),
            const SizedBox(height: 15),
            _buildMainButton("ابحث عن نبتتك", "assets/images/plant2.png"),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "أدوات العناية :",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildCareTools(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildMainButton(String text, String imagePath) {
    return GestureDetector(
      onTap: () {
        if (text == "اكتشف نبتتك") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF577363),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCareTools() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildToolButton("جدول الري", Icons.water_drop),
          _buildToolButton("الموقع وحالة الطقس", Icons.eco),
        ],
      ),
    );
  }

  Widget _buildToolButton(String text, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (text == "جدول الري") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const WateringScheduleScreen()),
          );
        }
      },
      child: Container(
        width: 150,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      color: const Color(0xFFB3BEA6),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFB3BEA6),
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color.fromARGB(153, 0, 0, 0),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.black),
            activeIcon: Icon(Icons.home, color: Colors.black),
            label: 'الصفحة الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist_outlined, color: Colors.black),
            activeIcon: Icon(Icons.local_florist, color: Colors.black),
            label: 'نبتاتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined, color: Colors.black),
            activeIcon: Icon(Icons.camera_alt, color: Colors.black),
            label: 'الكاميرا',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined, color: Colors.black),
            activeIcon: Icon(Icons.calendar_today, color: Colors.black),
            label: 'جدول الري',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/chat.png', width: 24, height: 24),
            label: 'مساعدة',
          ),
        ],
      ),
    );
  }
}
