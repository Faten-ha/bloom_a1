import 'package:flutter/material.dart';
import 'home_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF063D1D), // 0% أخضر داكن
              Color(0xFF577363), // 68% أخضر معتدل
              Color(0xFFA9A9A9), // 100% رمادي
            ],
            stops: [0.0, 0.68, 1.0], // تحديد النقاط على التدرج
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            // الشعار بشكل مربع مع الحجم الصحيح
            Image.asset(
              'assets/images/Logo_bloom.png',
              height: 274, // تعيين الارتفاع إلى 274
              width: 281, // تعيين العرض إلى 281
              fit: BoxFit.cover, // يعرض الصورة بشكل جيد داخل الإطار
            ),
            const SizedBox(height: 40),
            // استخدام Expanded و Align لجعل المربع يبدأ من أسفل الشاشة
            Expanded(
              child: Align(
                alignment:
                    Alignment.bottomCenter, // جعل المربع يبدأ من أسفل الشاشة
                child: _buildFormContainer(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFB3BEA6),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // تعديل حجم العمود ليناسب المحتوى
        children: [
          Text(
            "إنشاء حساب",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF20272B),
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField(
              icon: Icons.phone, hintText: "رقم الهاتف أو البريد الإلكتروني"),
          const SizedBox(height: 15),
          _buildTextField(
              icon: Icons.lock, hintText: "الرقم السري", obscureText: true),
          const SizedBox(height: 15),
          _buildTextField(
              icon: Icons.lock,
              hintText: "تأكيد الرقم السري",
              obscureText: true),
          const SizedBox(height: 25),
          _buildButton(context, text: "إنشاء حساب"),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required IconData icon,
      required String hintText,
      bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      style: TextStyle(),
      textAlign: TextAlign.center, // محاذاة النص في المنتصف
      decoration: InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(top: 8), // رفع الأيقونة إلى الأعلى
          child: icon == Icons.phone
              ? Transform.rotate(
                  angle: 4.5, // تدوير الأيقونة بمقدار أكبر (نحو اليسار)
                  child: Icon(
                    icon,
                    color: Color(0xFF577363),
                    size: 30,
                  ),
                )
              : Icon(
                  icon,
                  color: Color(0xFF577363),
                  size: 30,
                ), // القفل يبقى كما هو
        ),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String text}) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF577363),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 45),
        elevation: 5,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
