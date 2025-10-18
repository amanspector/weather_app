import 'dart:convert';
import 'package:http/http.dart' as http;

class services_api {
  final String _apiKey = "61c5b0b3d6a8263eec09533ea0164e24";

  Future<Map<String, dynamic>?> fetchWeather(double lat, double long) async {
    try {
      // final url = "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$long&exclude=minutely,hourly,alerts&appid=$_apiKey";
      final url = "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=ab451a51c0893846c6d678972d2abf79";
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