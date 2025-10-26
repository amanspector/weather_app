import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home_screen.dart';

class services_api {

    final _apiKey = dotenv.env['API_KEY'] ?? '';

    // Future<CityWeather?> fetchCityWeather(String cityName) async {
    //   final api = services_api();
    //
    //   // Step 1: geocode city to get lat/lon
    //   final results = await api.geocodeCity(cityName, limit: 1);
    //   if (results.isEmpty) return null;
    //
    //   final lat = (results[0]['lat'] as num).toDouble();
    //   final lon = (results[0]['lon'] as num).toDouble();
    //
    //   // Step 2: fetch weather using lat/lon
    //   final weatherData = await api.fetchWeather(lat, lon);
    //   if (weatherData == null) return null;
    //
    //   // Step 3: extract current weather
    //   final current = weatherData['current'];
    //   if (current == null) return null;
    //
    //   final temp = (current['temp'] as num).toDouble();
    //   final icon = current['weather'][0]['icon'];
    //
    //   return CityWeather(
    //     city: cityName,
    //     iconCode: icon,
    //     temp: temp,
    //     time: DateTime.now(),
    //   );
    // }


    Future<CityWeather?> fetchCityWeather(String cityName) async {
      final results = await geocodeCity(cityName, limit: 1);
      if (results.isEmpty) return null;

      final lat = (results[0]['lat'] as num).toDouble();
      final lon = (results[0]['lon'] as num).toDouble();

      final weatherData = await fetchWeather(lat, lon);
      if (weatherData == null) return null;

      final current = weatherData['current'];
      if (current == null) return null;

      final temp = (current['temp'] as num).toDouble();
      final icon = current['weather'][0]['icon'];

      return CityWeather(
        city: cityName,
        iconCode: icon,
        temp: temp,
        time: DateTime.now(),
      );
    }



    Future<List<Map<String,dynamic>>> geocodeCity(String query , {int limit =5}) async{
      if(query.isEmpty) return [];
      final encoded = Uri.encodeComponent(query);
      final url = 'http://api.openweathermap.org/geo/1.0/direct?q=$encoded&limit=$limit&appid=$_apiKey';

      try{
        final res =await http.get(Uri.parse(url));
        if(res.statusCode == 200){
          final data = jsonDecode(res.body);
          if(data is List){
            return data.map<Map<String,dynamic>>((e) => Map<String,dynamic>.from(e)).toList();
          }
        }
        else
          { print('Geocode failed: ${res.statusCode} ${res.body}');}
      }
      catch(e){
        print('Error : $e');
      }
      return [];
    }



    Future<Map<String, dynamic>?> fetchWeather(double lat, double long) async {
    try {
      // final url = "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$long&exclude=minutely,hourly,alerts&appid=$_apiKey";

      final url = "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$long&exclude=minutely,alerts&appid=$_apiKey&units=metric";
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