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

  final List<String> _title = [
    'الصفحة الرئيسية',
    'نباتاتي',
    'الكاميرا',
    'جدول الري',
    'المساعدة',
  ];
  void _shareAccountLink() {
    // هنا يمكن إضافة منطق مشاركة الرابط
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت مشاركة رابط الحساب')),
    );
  }

  void _logout() {
    // هنا يمكن إضافة منطق تسجيل الخروج
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تسجيل الخروج')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF063D1D) ,
          elevation: 0,
          title: Center(
            child: Text(
              _title[_selectedIndex],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF063D1D),
              ),
            ),
          ),
        ),
        endDrawer: Drawer(

          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3C1E),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.account_circle, size: 80, color: Colors.white),
                    SizedBox(height: 10),
                    Text("مرحبًا بك",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("مشاركة رابط الحساب"),
                onTap: _shareAccountLink,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("تسجيل خروج"),
                onTap: _logout,
              ),
            ],
          ),
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar:
        _buildBottomNavBar(),
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
