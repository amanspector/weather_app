import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _city = "Fetch Location.......";
  String _temperature = "--°C";
  String _condition = "Loading...";
  bool _isLoading = true;
  String _humidity ='--';
  String _wind_speed='--';
  String _pressure ='--';
  Map<String, dynamic>? _weatherData;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async{
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      setState(() => _city = "Location service disable.");
      _isLoading = false;
    return;
    }

    permission= await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        setState(() {
          _city= "Permission denied.";
          _isLoading = false;
        });
        return;
    }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _city = "Permissions permanently denied.";
        _isLoading = false;
      });
      return;
    }

    try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    String city = placemarks.isNotEmpty?placemarks[0].locality??"unknown" : "unknown";
    final weatherdata = await services_api().fetchWeather(position.latitude, position.longitude);

    print("Weather data: $weatherdata");
    // if(weatherdata!= null){
    //   setState(() {
    //     _city = city;
    //     _temperature = "${weatherdata['main']['temp'].toStringAsFixed(1)}°C";
    //     _condition = weatherdata["weather"][0]["main"];
    //     _isLoading = false;
    //   });
    // }

    // if (placemarks.isNotEmpty) {
    //   Placemark place = placemarks[0];
    //   setState(() {
    //     _city = place.locality ?? "Unknown City";
    //     _isLoading = false;
    //     _temperature = "30°C";
    //     _condition = "Partly Cloudy";
    //   });
    // } else {
    //   setState(() {
    //     _city = "City not found";
    //     _isLoading = false;
    //   });
    // }

    if (weatherdata != null) {
      var current = weatherdata['current'];
      var tem = current['temp'];
      var condition = current['weather'][0]['description'];
      var humidity = current['humidity'];
      var wind_speed = current['wind_speed'];
      var pressure = current['pressure'];

      setState(() {
        _city = city;
        _temperature =
        (tem is num) ? "${tem.toStringAsFixed(1)}°C" : "--°C";
        _condition = condition ?? "--";
        _humidity = humidity.toString();
        _wind_speed = wind_speed.toString();
        _pressure = pressure.toString();
        _isLoading = false;
      });
    } else {
      setState(() {
        _city = city;
        _condition = "Unable to fetch weather";
      });
    }
  } catch (e) {
  setState(() {
  _city = "Error fetching location";
  _condition = "Error";
  _isLoading = false;
  });
  print("Error in _getCurrentLocation: $e");
  }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B0E11),
      body: SafeArea(
          child:_isLoading?
              Center(child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ),)

              
              :SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildCurrentWeather(),
                const SizedBox(height: 20),
                buildTodayForecast(),
                const SizedBox(height: 20),
                buildWeeklyForecast(),
                const SizedBox(height: 20),
                buildAirConditions(),
              ],
        //       children: [
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Icon(Icons.location_on ,color: Colors.blueAccent,),
        //             SizedBox(width: 8,),
        //             Text("Hidden hehe",style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 28,
        //               fontWeight: FontWeight.bold,
        //             ),)
        //           ],
        //         ),
        //         SizedBox(height: 40),
        //         Icon(
        //           Icons.wb_sunny_rounded,
        //           color: Colors.orangeAccent,
        //           size: 100,
        //         ),
        //
        //         SizedBox(height: 20,),
        //
        //         Text(
        //           _temperature,
        //           style: TextStyle(
        //             color: Colors.white,
        //             fontSize: 64,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //
        //         Text(
        //           _condition,
        //           style: const TextStyle(
        //             color: Colors.white70,
        //             fontSize: 22,
        //           ),
        //         ),
        //
        //         SizedBox(height: 10),
        //
        //         Column(
        //           children: [
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               crossAxisAlignment: CrossAxisAlignment.center,
        //               children: [
        //                 Icon(Icons.opacity,color: Colors.blueAccent,),
        //                 Text(_humidity,style: TextStyle(
        //                   color: Colors.white,
        //                   fontSize: 40,
        //                   fontWeight: FontWeight.bold,
        //                 ),),
        //         ],
        //             ),
        //           ],
        //         ),
        //
        //         SizedBox(height: 10),
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Icon(Icons.air,color: Colors.white,),
        //             Text(_wind_speed,style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 40,
        //               fontWeight: FontWeight.bold,
        //             ),),
        //
        //           ],
        //         ),
        //         SizedBox(height: 10),
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Icon(Icons.speed,color: Colors.redAccent,),
        //             Text(_pressure,style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 40,
        //               fontWeight: FontWeight.bold,
        //             ),),
        //           ],
        //         ),
        //
        //         SizedBox(height: 20),
        //
        //         ElevatedButton.icon(
        //           onPressed: _getCurrentLocation,
        //           style: ElevatedButton.styleFrom(
        //             backgroundColor: Colors.blueAccent,
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(30),
        //             ),
        //             padding: const EdgeInsets.symmetric(
        //                 horizontal: 25, vertical: 15),
        //           ),
        //           icon: const Icon(Icons.refresh, color: Colors.white),
        //           label: const Text(
        //             "Refresh",
        //             style: TextStyle(
        //                 color: Colors.white, fontWeight: FontWeight.w600),
        //           ),
        //         ),
        // ],
            ),
          ),
      ),
      bottomNavigationBar: buildBottomNav(),
    );
  }

Widget buildCurrentWeather() {

  final current = _weatherData!['current'];
  final temp = current['temp'].toStringAsFixed(1);
  final condition = current['weather'][0]['description'];
  final icon = current['weather'][0]['icon'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _city,style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        ),

        SizedBox(height: 8,),
        Text(
          "Chance of rain: 0%", // optional dynamic
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        Container(
          // decoration: BoxDecoration(
          //   shape: BoxShape.circle,
          //   gradient: RadialGradient(colors: [Colors.yellow ,Colors.orangeAccent],
          //   radius: 0.8),
          //
          // ),
          padding: EdgeInsets.all(45),
          child: Icon(
            Icons.wb_sunny_rounded,
            size: 100,
            color: Colors.orangeAccent,
          ),
        ),
        SizedBox(height: 25,),
        Text(_temperature,style: TextStyle(
          color: Colors.white,
          fontSize: 64,
          fontWeight: FontWeight.bold,
        ),)
      ],
    );
}

  Widget buildTodayForecast() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TODAY’S FORECAST",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                forecastItem("9:00 AM", Icons.wb_sunny, "25°"),
                const SizedBox(width: 16),
                forecastItem("12:00 PM", Icons.wb_sunny, "28°"),
                const SizedBox(width: 16),
                forecastItem("3:00 PM", Icons.wb_sunny, "33°"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget forecastItem(String time, IconData icon, String temp) {
    return Column(
      children: [
        Text(time, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Icon(icon, color: Colors.yellowAccent, size: 40),
        const SizedBox(height: 8),
        Text(temp,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildWeeklyForecast() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "7-DAY FORECAST",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          dayForecastItem("Today", Icons.wb_sunny, "36/22"),
          dayForecastItem("Tue", Icons.wb_sunny, "37/21"),
          dayForecastItem("Wed", Icons.wb_sunny, "37/21"),
          dayForecastItem("Thu", Icons.cloud, "37/21"),
          dayForecastItem("Fri", Icons.cloud, "37/21"),
          dayForecastItem("Sat", Icons.beach_access, "37/21"),
          dayForecastItem("Sun", Icons.wb_sunny, "37/21"),
        ],
      ),
    );
  }

  Widget dayForecastItem(String day, IconData icon, String temp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Icon(icon, color: Colors.yellow),
          Text(temp,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildAirConditions() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "AIR CONDITIONS",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("See more",
                    style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              airConditionItem("Real Feel", "30°"),
              airConditionItem("Wind", "0.2 km/h"),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              airConditionItem("Chance of rain", "0%"),
              airConditionItem("UV Index", "3"),
            ],
          ),
        ],
      ),
    );
  }

  Widget airConditionItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 5,width: 75,),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1E2228),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.cloud), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
      ],
    );
  }

}

