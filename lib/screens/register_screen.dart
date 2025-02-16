import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // ضمان الامتداد الكامل
        height: double.infinity, // ضمان الامتداد الكامل
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E734E), Color(0xFF1E3C1E)], // لون متدرج للخلفية
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Image.asset('assets/images/bloom_assist.png', height: 250),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "إما من مسلم يغرس غرساً أو يزرع زرعاً \n فيأكل منه طير أو إنسان إلا كان له به صدقة",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            _buildButton(context, "إنشاء حساب", const SignUpScreen()),
            const SizedBox(height: 15),
            _buildButton(context, "تسجيل دخول", const LoginScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget screen) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDCE3C6), // لون مطابق للتصميم
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
      ),
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }
}
