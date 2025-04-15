import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  Position? position;
  double temperature = 0.0;
  String weatherCondition = "--";
  bool isLoading = true;
  String errorMessage = "";

  final String apiKey = "5636a30b4ad0c22d1c43b749606f1f4d";

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
      position = await _determinePosition();
      final weatherData =
          await _fetchWeatherFromAPI(position!.latitude, position!.longitude);

      setState(() {
        temperature = weatherData['main']['temp']?.toDouble() ?? 0.0;
        weatherCondition = weatherData['weather'][0]['description'] ?? "--";
      });
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw "الرجاء تفعيل خدمة الموقع";
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw "تم رفض إذن الموقع";
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> _fetchWeatherFromAPI(
      double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=ar',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw "فشل في جلب بيانات الطقس: ${response.statusCode}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات الطقس'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : errorMessage.isNotEmpty
                ? Text(errorMessage)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'الموافق: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'خط العرض: ${position?.latitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'خط الطول: ${position?.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'درجة الحرارة: ${temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'حالة الطقس: $weatherCondition',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _fetchWeatherData,
                        child: const Text('موافق'),
                      ),
                    ],
                  ),
      ),
    );
  }
}
