import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String location = "جاري تحديد الموقع...";
  String temperature = "--";
  String weatherCondition = "--";
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      Position? position = await _determinePosition();
      if (position != null) {
        setState(() {
          location =
              "خط العرض: ${position.latitude}, خط الطول: ${position.longitude}";
          temperature = "25"; // استبدل هذا لاحقًا بجلب البيانات الحقيقية
          weatherCondition = "مشمس"; // استبدل هذا لاحقًا بجلب البيانات الحقيقية
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق مما إذا كانت خدمة الموقع مفعلة
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw "خدمة الموقع غير مفعلة. يرجى تفعيل GPS من الإعدادات.";
    }

    // التحقق من حالة الإذن
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw "تم رفض إذن الموقع.";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw "تم رفض الإذن نهائيًا. يرجى تمكينه من إعدادات الهاتف.";
    }

    // الحصول على الموقع
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة الطقس'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // عرض مؤشر تحميل أثناء جلب البيانات
            : errorMessage.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 20, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchWeatherData,
                        child: const Text("إعادة المحاولة"),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'الموقع: $location',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'درجة الحرارة: $temperature°C',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'الحالة: $weatherCondition',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
      ),
    );
  }
}
