import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Position? _position;
  double _temperature = 0.0;
  String _weatherCondition = "جاري التحميل...";
  bool _isLoading = true;
  String _errorMessage = "";
  String _locationName = "";

  // TODO: استبدل بمفتاح API الخاص بك من OpenWeatherMap
  final String _apiKey = "YOUR_API_KEY_HERE";

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      _position = await _getCurrentPosition();
      final weatherData = await _fetchWeatherFromAPI(
        _position!.latitude,
        _position!.longitude,
      );

      setState(() {
        _temperature = weatherData['main']['temp']?.toDouble() ?? 0.0;
        _weatherCondition = _translateWeatherCondition(
          weatherData['weather'][0]['description'] ?? "",
        );
        _locationName = weatherData['name'] ?? "موقع غير معروف";
      });
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw "تفعيل خدمة الموقع مطلوب";
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
        'https://api.openweathermap.org/data/2.5/weather?'
        'lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=ar',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw "خطأ في جلب البيانات: ${response.statusCode}";
    }
  }

  String _translateWeatherCondition(String condition) {
    const translations = {
      'clear sky': 'سماء صافية',
      'few clouds': 'قليل من السحب',
      'scattered clouds': 'سحب متفرقة',
      'broken clouds': 'غيوم',
      'shower rain': 'أمطار خفيفة',
      'rain': 'أمطار',
      'thunderstorm': 'عاصفة رعدية',
      'snow': 'ثلج',
      'mist': 'ضباب',
    };
    return translations[condition.toLowerCase()] ?? condition;
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains("location")) {
      return "خطأ في الموقع: ${error.toString().replaceAll("Exception: ", "")}";
    }
    return "حدث خطأ: ${error.toString().replaceAll("Exception: ", "")}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة الطقس'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeatherData,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _buildWeatherContent(),
    );
  }

  Widget _buildWeatherContent() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorView();
    }

    return _buildWeatherView();
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('جاري جلب بيانات الطقس...'),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchWeatherData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildLocationCard(),
          const SizedBox(height: 20),
          _buildWeatherCard(),
          const SizedBox(height: 20),
          _buildRefreshButton(),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _locationName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'التاريخ: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'الإحداثيات: ${_position?.latitude.toStringAsFixed(4)}, '
              '${_position?.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${_temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _weatherCondition,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return ElevatedButton(
      onPressed: _fetchWeatherData,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: const Text('تحديث البيانات'),
    );
  }
}
