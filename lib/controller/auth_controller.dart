import 'package:bloom_a1/models/user_table.dart';
import 'package:bloom_a1/screens/login_screen.dart';
import 'package:bloom_a1/screens/splash_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/db_helper.dart';

class AuthController extends GetxController {
  final dbHelper = DBHelper();
  final currentUser = Rxn<UserTable>();

  /// Signup a new user and save to local DB
  Future<String?> signUp(String emailOrPhone, String password) async {
    final existingUser = await dbHelper.getUserByEmailOrPhone(emailOrPhone);
    if (existingUser != null) {
      return 'المستخدم موجود بالفعل';
    }

    final newUser = UserTable(
      emailOrPhone: emailOrPhone,
      password: password,
    );

    int userId = await dbHelper.insertUser(newUser);
    final savedUser =
        UserTable(id: userId, emailOrPhone: emailOrPhone, password: password);
    await saveUserToPrefs(savedUser);
    currentUser.value = savedUser;
    return null; // success
  }

  /// Login user
  Future<String?> login(String emailOrPhone, String password) async {
    final user = await dbHelper.getUserByEmailOrPhone(emailOrPhone);
    if (user == null || user.password != password) {
      return 'البريد الإلكتروني/الهاتف أو كلمة المرور غير صالحة';
    }
    await saveUserToPrefs(user);
    currentUser.value = user;
    return null; // success
  }

  /// Save user to shared preferences
  Future<void> saveUserToPrefs(UserTable user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id!);
    await prefs.setString('emailOrPhone', user.emailOrPhone);
    await prefs.setString('password', user.password);
  }

  /// Load user from shared preferences
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    final emailOrPhone = prefs.getString('emailOrPhone');
    final password = prefs.getString('password');

    if (id != null && emailOrPhone != null && password != null) {
      currentUser.value =
          UserTable(id: id, emailOrPhone: emailOrPhone, password: password);
    }
  }

  /// Logout user and clear shared preferences
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentUser.value = null;
    Get.offAll(()=>SplashScreen());
  }
}
