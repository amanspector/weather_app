import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class services_api {
  Future<Map<String, dynamic>?> fetchWeather(double lat, double long) async {
    try {
      // final url = "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$long&exclude=minutely,hourly,alerts&appid=$_apiKey";
      final _apiKey = dotenv.env['API_KEY'] ?? '';
      final url = "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$long&exclude=minutely,hourly,alerts&appid=$_apiKey&units=metric";
      // final url = "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=$_apiKey";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      else {
        print("Failed to load data ${response.statusCode}");
      }
    }
    catch (e) {
      print("Error fetching weather: $e");
    }
    return null;
  }
}