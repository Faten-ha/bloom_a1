import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_plants_screen.dart';
import 'camera_screen.dart';
import 'watering_schedule_screen.dart';
import 'chatbot_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloom_a1/controller/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _recognizedText = "";
  String cityName = "جاري التحديد...";
  String temperature = "--";
  String weatherDescription = "--";
  String humidity = "--";
  String windSpeed = "--";
  bool _isLoading = false;
  String weatherIcon = "";
  bool _locationPermissionRequested = false;
  final AuthController authController = Get.find<AuthController>();

  final String apiKey = "5636a30b4ad0c22d1c43b749606f1f4d";

  // قائمة بالأوامر الصوتية المتاحة
  final Map<String, List<String>> voiceCommands = {
    'my_plants': ['نباتي', 'نبتاتي', 'نبات'],
    'camera': ['الكاميرا'],
    'watering_schedule': ['جدول', 'ري', 'جدول الري', 'جدولي', 'التقويم'],
    'home': ['الصفحة الرئيسية', 'الرئيسية', 'صفحة', 'رئيسية'],
    'chatbot': [
      'مساعدة',
      'المساعدة',
      'ساعدني',
      'ذكاء اصطناعي',
      'شات',
      'مساعده',
      'شات بوت'
    ],
    'location': ['موقع', 'الموقع', 'مكان', 'أين', 'طقس'],
    'logout': ['تسجيل خروج', 'خروج', 'تسجيل الخروج', 'اخرج', 'تسجيل']
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _initializeSpeechToText();
    _loadLocationPermissionStatus();
  }

  Future<void> _loadLocationPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _locationPermissionRequested =
          prefs.getBool('locationPermissionRequested') ?? false;
    });

    if (!_locationPermissionRequested) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLocationDialog();
      });
    }
  }

  Future<void> _saveLocationPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('locationPermissionRequested', true);
  }

  void _initializeSpeechToText() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => debugPrint("Status: $status"),
      onError: (error) => debugPrint("Error: $error"),
    );

    if (!available) {
      _showSnackbar("التعرف على الكلام غير متاح!");
    }
  }

  void _startListening() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      _showSnackbar("جاري الاستماع...");
      _speechToText.listen(
        localeId: "ar_SA",
        onResult: (result) {
          setState(() => _recognizedText = result.recognizedWords);
          if (result.finalResult) {
            _handleVoiceCommand(_recognizedText);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  void _handleVoiceCommand(String command) {
    debugPrint("Recognized command: $command");
    command = command.trim().toLowerCase();
    bool commandRecognized = false;

    if (_hasKeyword(command, voiceCommands['my_plants']!)) {
      _navigateToMyPlantsScreen();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['camera']!)) {
      _navigateToCameraScreen();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['watering_schedule']!)) {
      _navigateToWateringScheduleScreen();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['home']!)) {
      _navigateToHomeScreen();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['chatbot']!)) {
      _navigateToChatBotScreen();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['location']!)) {
      _showLocationDialog();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['logout']!)) {
      _logout();
      commandRecognized = true;
    }

    if (!commandRecognized) {
      _showSnackbar("لم يتم التعرف على الأمر!");
    }

    _stopListening();
  }

  bool _hasKeyword(String text, List<String> keywords) {
    text = text.trim().toLowerCase();
    for (var keyword in keywords) {
      if (text == keyword || text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  void _stopListening() {
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  void _logout() {
    _showLogoutDialog(executeLogout: true);
  }

  void _performLogout() async {
    try {
      Get.snackbar(
        'تنبيه',
        'تم تسجيل الخروج بنجاح',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await authController.logout();
    } catch (e) {
      debugPrint("Error during logout: $e");
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الخروج',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showHelpScreen() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF577363),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(screenWidth * 0.05),
        height: screenHeight * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: screenWidth * 0.1,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.white.withAlpha(128),
                    borderRadius: BorderRadius.circular(10))),
            SizedBox(height: screenHeight * 0.02),
            Text("الأوامر الصوتية المتاحة",
                style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center),
            SizedBox(height: screenHeight * 0.01),
            const Divider(color: Colors.white24),
            SizedBox(height: screenHeight * 0.01),
            Expanded(
              child: ListView(
                children: [
                  _buildHelpSection(
                      "نبتاتي",
                      "قل: \"نباتي\" أو \"نبتاتي\" للانتقال إلى صفحة النباتات",
                      Icons.local_florist,
                      screenWidth),
                  _buildHelpSection(
                      "الكاميرا",
                      "قل: \"الكاميرا\" للانتقال إلى صفحة الكاميرا",
                      Icons.camera_alt,
                      screenWidth),
                  _buildHelpSection(
                      "جدول الري",
                      "قل: \"جدول الري\" أو \"ري\" أو \"التقويم\"",
                      Icons.water_drop,
                      screenWidth),
                  _buildHelpSection(
                      "المساعدة",
                      "قل: \"مساعدة\" أو \"شات\" أو \"ذكاء اصطناعي\"",
                      Icons.chat,
                      screenWidth),
                  _buildHelpSection(
                      "الموقع والطقس",
                      "قل: \"موقع\" أو \"طقس\" لعرض معلومات الطقس",
                      Icons.cloud,
                      screenWidth),
                  _buildHelpSection(
                      "تسجيل الخروج",
                      "قل: \"تسجيل خروج\" أو \"خروج\" للخروج من التطبيق",
                      Icons.logout,
                      screenWidth),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF204D32),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, screenHeight * 0.06),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text("حسنا",
                  style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(
      String title, String description, IconData icon, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.05),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
                color: const Color(0xFF204D32),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: screenWidth * 0.06),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.right),
                SizedBox(height: screenWidth * 0.01),
                Text(description,
                    style: TextStyle(
                        fontSize: screenWidth * 0.035, color: Colors.white70),
                    textAlign: TextAlign.right),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog({bool executeLogout = false}) {
    if (executeLogout) {
      _performLogout();
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text("تسجيل الخروج"),
        content: Text("هل أنت متأكد أنك تريد تسجيل الخروج؟"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performLogout();
            },
            child: Text("تسجيل خروج", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _navigateToMyPlantsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyPlantsScreen()),
    );
  }

  void _navigateToCameraScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen()),
    );
  }

  void _navigateToWateringScheduleScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WateringScheduleScreen()),
    );
  }

  void _navigateToChatBotScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatBotScreen()),
    );
  }

  void _navigateToHomeScreen() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _showSnackbar(String message) {
    Get.snackbar(
      'تنبيه',
      message,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyPlantsScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WateringScheduleScreen()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatBotScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showLocationDialog() {
    if (_locationPermissionRequested) {
      _fetchLocationData();
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("هل ترغب في مشاركة موقعك الحالي؟"),
          content: Text("سنستخدم موقعك لعرض معلومات الطقس لمدينتك"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _saveLocationPermissionStatus();
                setState(() {
                  _locationPermissionRequested = true;
                });
                await _fetchLocationData();
              },
              child: Text("نعم"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _saveLocationPermissionStatus();
                setState(() {
                  _locationPermissionRequested = true;
                });
              },
              child: Text("لا"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchLocationData() async {
    setState(() => _isLoading = true);
    try {
      Position? position = await _determinePosition();
      if (position != null) {
        debugPrint(
            "موقع تم الحصول عليه: ${position.latitude}, ${position.longitude}");
        await _getCityName(position.latitude, position.longitude);
        await _fetchWeatherDataByCoordinates(
            position.latitude, position.longitude);
      }
    } catch (e) {
      setState(() {
        cityName = "خطأ في تحديد الموقع";
        temperature = "غير متاح";
        weatherDescription = "غير متاح";
        humidity = "غير متاح";
        windSpeed = "غير متاح";
      });
      _showSnackbar("خطأ في تحديد الموقع: ${e.toString()}");
      debugPrint("Error in _fetchLocationData: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar("خدمة الموقع غير مفعلة. يرجى تفعيل GPS من الإعدادات.");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar("تم رفض إذن الموقع.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackbar("تم رفض الإذن نهائيًا. يرجى تمكينه من إعدادات الهاتف.");
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  Future<void> _getCityName(double lat, double lon) async {
    try {
      debugPrint("جاري البحث عن المدينة بالإحداثيات: $lat, $lon");
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1&accept-language=ar'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("بيانات الاستجابة: $data");

        String? city;
        if (data['address'] != null) {
          city = data['address']['city'] ??
              data['address']['town'] ??
              data['address']['village'] ??
              data['address']['suburb'] ??
              data['address']['neighbourhood'] ??
              data['address']['county'] ??
              data['address']['state'] ??
              data['address']['country'] ??
              "موقع غير معروف";
        }

        setState(() {
          cityName = city ?? "موقع غير معروف";
        });

        debugPrint("تم تحديد المدينة: $cityName");
      } else {
        debugPrint("خطأ في استجابة API: ${response.statusCode}");
        setState(() => cityName = "تعذر تحديد المدينة");
      }
    } catch (e) {
      setState(() => cityName = "تعذر تحديد المدينة");
      debugPrint("Error getting city name: $e");
    }
  }

  Future<void> _fetchWeatherDataByCoordinates(double lat, double lon) async {
    try {
      debugPrint("جاري جلب بيانات الطقس للإحداثيات: $lat, $lon");
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=ar'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("بيانات الطقس: $data");
        setState(() {
          temperature = "${data['main']['temp']?.toStringAsFixed(1) ?? '--'}°C";
          weatherDescription = data['weather'][0]['description'] ?? "--";
          humidity = "${data['main']['humidity']?.toString() ?? '--'}%";
          windSpeed = "${(data['wind']['speed'] ?? 0).toStringAsFixed(1)} م/ث";
          weatherIcon = data['weather'][0]['icon'] ?? "";
        });
        _showWeatherInfoDialog();
      } else {
        debugPrint("خطأ في استجابة API الطقس: ${response.statusCode}");
        _showSnackbar("تعذر جلب بيانات الطقس");
      }
    } catch (e) {
      debugPrint("Error fetching weather: $e");
      _showSnackbar("حدث خطأ أثناء جلب بيانات الطقس");
    }
  }

  Future<void> _fetchWeatherData(String city) async {
    try {
      debugPrint("جاري جلب بيانات الطقس للمدينة: $city");
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=ar'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("بيانات الطقس: $data");
        setState(() {
          temperature = "${data['main']['temp']?.toStringAsFixed(1) ?? '--'}°C";
          weatherDescription = data['weather'][0]['description'] ?? "--";
          humidity = "${data['main']['humidity']?.toString() ?? '--'}%";
          windSpeed = "${(data['wind']['speed'] ?? 0).toStringAsFixed(1)} م/ث";
          weatherIcon = data['weather'][0]['icon'] ?? "";
        });
        _showWeatherInfoDialog();
      } else {
        debugPrint("خطأ في استجابة API الطقس: ${response.statusCode}");
        _showSnackbar("تعذر جلب بيانات الطقس");
      }
    } catch (e) {
      debugPrint("Error fetching weather: $e");
      _showSnackbar("حدث خطأ أثناء جلب بيانات الطقس");
    }
  }

  void _showWeatherInfoDialog() {
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("معلومات الطقس في $cityName"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (weatherIcon.isNotEmpty)
                  Center(
                    child: Image.network(
                      'https://openweathermap.org/img/wn/$weatherIcon@2x.png',
                      width: screenWidth * 0.25,
                      height: screenWidth * 0.25,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.cloud, size: screenWidth * 0.2);
                      },
                    ),
                  ),
                _buildWeatherInfoRow("درجة الحرارة", temperature),
                _buildWeatherInfoRow("حالة الطقس", weatherDescription),
                _buildWeatherInfoRow("الرطوبة", humidity),
                _buildWeatherInfoRow("سرعة الرياح", windSpeed),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  "آخر تحديث: ${DateTime.now().toString().substring(0, 16)}",
                  style: TextStyle(
                      fontSize: screenWidth * 0.03, color: Colors.grey),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  "الإحداثيات: يتم عرض معلومات الطقس لموقعك الدقيق",
                  style: TextStyle(
                      fontSize: screenWidth * 0.03, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("إغلاق"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _fetchLocationData();
              },
              child: Text("تحديث"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeatherInfoRow(String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.035,
              )),
          Text(value,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
              )),
        ],
      ),
    );
  }

  Widget _buildMainButton(String text, String imagePath) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        if (text == "اكتشف نبتتك") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CameraScreen()),
          );
        } else if (text == "ابحث عن نبتتك") {
          _navigateToMyPlantsScreen();
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Container(
          height: screenHeight * 0.12,
          decoration: BoxDecoration(
            color: const Color(0xFF577363),
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(screenWidth * 0.04),
                  bottomRight: Radius.circular(screenWidth * 0.04),
                ),
                child: Image.asset(
                  imagePath,
                  width: screenWidth * 0.25,
                  height: screenHeight * 0.12,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
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
                      icon: Icon(Icons.help_outline,
                          color: Color(0xFF204D32), size: screenWidth * 0.07),
                      onPressed: _showHelpScreen,
                      tooltip: 'مساعدة الأوامر الصوتية',
                    ),
                    title: Text(
                      "الصفحة الرئيسية",
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF063D1D),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.logout,
                            color: Color(0xFF063D1D), size: screenWidth * 0.07),
                        onPressed: () => _showLogoutDialog(),
                      ),
                    ],
                    centerTitle: true,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showLocationDialog();
                          },
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 0.2),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.cloud,
                                    color: Colors.white,
                                    size: screenWidth * 0.06),
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  temperature != "--" ? temperature : "الطقس",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          "مرحبًا",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF063D1D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildMainButton("اكتشف نبتتك", "assets/images/plant1.png"),
                  SizedBox(height: screenHeight * 0.015),
                  _buildMainButton("ابحث عن نبتتك", "assets/images/plant2.png"),
                  SizedBox(height: screenHeight * 0.015),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        ":أدوات العناية ",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildCareTools(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: _startListening,
            backgroundColor: _isListening
                ? const Color(0xFF204D32)
                : const Color(0xFFCDD4BA),
            child: Icon(Icons.mic,
                color: _isListening ? Colors.white : Colors.black,
                size: screenWidth * 0.07),
          ),
          if (_isListening)
            const Positioned.fill(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomSheet: _isListening
          ? Container(
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.05),
              color: const Color(0xFF204D32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _recognizedText.isNotEmpty
                        ? "التعرف على: $_recognizedText"
                        : "جاري الاستماع...",
                    style: TextStyle(
                        color: Colors.white, fontSize: screenWidth * 0.04),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _stopListening,
                        child: Text("إلغاء",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.035)),
                      ),
                      TextButton(
                        onPressed: _showHelpScreen,
                        child: Text("مساعدة",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.035)),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildCareTools() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildToolButton("جدول الري", Icons.water_drop),
          _buildToolButton("معلومات الطقس", Icons.cloud),
        ],
      ),
    );
  }

  Widget _buildToolButton(String text, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        if (text == "جدول الري") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WateringScheduleScreen()),
          );
        } else if (text == "معلومات الطقس") {
          _showLocationDialog();
        }
      },
      child: Container(
        width: screenWidth * 0.4,
        height: screenHeight * 0.12,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.2),
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: screenWidth * 0.1, color: Colors.black),
            SizedBox(height: screenHeight * 0.01),
            Text(
              text,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: const Color(0xFFB3BEA6),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFB3BEA6),
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color.fromARGB(153, 0, 0, 0),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedFontSize: screenWidth * 0.03,
        unselectedFontSize: screenWidth * 0.03,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined,
                color: Colors.black, size: screenWidth * 0.06),
            activeIcon:
                Icon(Icons.home, color: Colors.black, size: screenWidth * 0.06),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist_outlined,
                color: Colors.black, size: screenWidth * 0.06),
            activeIcon: Icon(Icons.local_florist,
                color: Colors.black, size: screenWidth * 0.06),
            label: 'نبتاتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined,
                color: Colors.black, size: screenWidth * 0.06),
            activeIcon: Icon(Icons.camera_alt,
                color: Colors.black, size: screenWidth * 0.06),
            label: 'الكاميرا',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined,
                color: Colors.black, size: screenWidth * 0.06),
            activeIcon: Icon(Icons.calendar_today,
                color: Colors.black, size: screenWidth * 0.06),
            label: 'جدول الري',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/chat.png',
                width: screenWidth * 0.06, height: screenWidth * 0.06),
            label: 'مساعدة',
          ),
        ],
      ),
    );
  }
}
