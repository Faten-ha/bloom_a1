import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey =
      'YOUR_OPENWEATHERMAP_API_KEY'; // استبدل بمفتاح API الخاص بك
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=ar'), // استخدام وحدات القياس المترية واللغة العربية
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('فشل في جلب بيانات الطقس');
    }
  }
}
