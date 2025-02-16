import 'package:flutter/material.dart';
import 'home_screen.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key}); // تأكد من أن الكلاس ليس Private

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, size: 30, color: Color(0xFF063D1D)),
      onPressed: () {
        // فتح القائمة داخل الصفحة الرئيسية كـ Dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF577363), // لون الخلفية
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      },
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFF577363), // نفس اللون في الصفحة الرئيسية
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
    );
  }
}
