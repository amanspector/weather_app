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
  List<Map<String, dynamic>> _next24Hours = [];
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
      var hourlyData = weatherdata['hourly'];
      var daily = weatherdata['daily'];
      var tem = current['temp'];
      var condition = current['weather'][0]['description'];
      var humidity = current['humidity'];
      var wind_speed = current['wind_speed'];
      var pressure = current['pressure'];
      var next24Hours = getNext24Hours(hourlyData);

      setState(() {
        _city = city;
        _temperature =
        (tem is num) ? "${tem.toStringAsFixed(1)}°C" : "--°C";
        _condition = condition ?? "--";
        _humidity = humidity.toString();
        _wind_speed = wind_speed.toString();
        _pressure = pressure.toString();
        _next24Hours = next24Hours;
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
                // const SizedBox(height: 20),
                // buildHourlyForcast(),
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
          padding: EdgeInsets.all(30),
          child: Icon(
            Icons.wb_sunny_rounded,
            size: 100,
            color: Colors.orangeAccent,
          ),
        ),
        // SizedBox(height: 5,),
        Text(_temperature,style: TextStyle(
          color: Colors.white,
          fontSize: 64,
          fontWeight: FontWeight.bold,
        ),)
      ],
    );
}

Widget buildTodayForecast(){
    if(_next24Hours.isEmpty){
      return SizedBox();
    }
    String? lastDate;

    return Container(
      decoration:BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(20),
      ) ,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      // height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
         Text(
              "NEXT 24 HOURS FORECAST",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          SizedBox(height: 5,),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
                itemCount: _next24Hours.length,
                itemBuilder: (context,index) {
                final hour = _next24Hours[index];
                final time = DateTime.fromMillisecondsSinceEpoch(hour['dt']*1000);
                final hourString = "${time.hour % 12 == 0 ? 12 : time.hour % 12} ${time.hour >= 12 ? 'PM' : 'AM'}";
                final dateString = "${time.day}/${time.month}";
                final icon = hour['weather'][0]['icon'];
                final temp = hour['temp'].toStringAsFixed(1);
                return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dateString, style:  TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),),
                        Text(hourString, style: TextStyle(color: Colors.white,fontSize: 14)),
                        SizedBox(height: 5,),
                        Image.network(
                          "https://openweathermap.org/img/wn/$icon.png",
                          height: 40,
                        ),
                        Text("$temp°C", style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                );
            }),
          ),
        ],
      ),
    );
}

  // Widget buildTodayForecast() {
  //   return Container(
  //     height: 120,
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF1E2228),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           "NEXT 24 HOURS FORECAST",
  //           style: TextStyle(
  //               color: Colors.white70,
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500),
  //         ),
  //         const SizedBox(height: 12),
  //         Container(
  //           child: ListView.builder(
  //               scrollDirection: Axis.horizontal,
  //               itemCount: _next24Hours.length,
  //               itemBuilder: (context,index) {
  //                 final hour = _next24Hours[index];
  //                 final time = DateTime.fromMillisecondsSinceEpoch(hour['dt']*1000);
  //                 // Hour in 12-hour format
  //                 final hourString = "${time.hour % 12 == 0 ? 12 : time.hour % 12} ${time.hour >= 12 ? 'PM' : 'AM'}";
  //                 // Date string
  //                 final dateString = "${time.day}/${time.month}";
  //                 bool showDate = true;
  //                 // if (lastDate != dateString) {
  //                 //   showDate = true;
  //                 //   lastDate = dateString;
  //                 // }
  //                 final icon = hour['weather'][0]['icon'];
  //                 final temp = hour['temp'].toStringAsFixed(1);
  //
  //                 return Container(
  //                   width: 80,
  //                   margin: const EdgeInsets.all(6),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white.withOpacity(0.2),
  //                     borderRadius: BorderRadius.circular(16),
  //                   ),
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       if (showDate)
  //                         Text(dateString, style:  TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),),
  //                       Text(hourString, style: TextStyle(color: Colors.white,fontSize: 14)),
  //                       SizedBox(height: 5,),
  //                       Image.network(
  //                         "https://openweathermap.org/img/wn/$icon.png",
  //                         height: 40,
  //                       ),
  //                       Text("$temp°C", style: const TextStyle(color: Colors.white)),
  //                     ],
  //                   ),
  //                 );
  //               }),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
              airConditionItem("Humidity","$_humidity"),
              airConditionItem("Wind","$_wind_speed"),
              airConditionItem("Pressure","$_pressure"),
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

  List<Map<String, dynamic>> getNext24Hours(List<dynamic> hourlyData) {
    final now = DateTime.now();
    final next24 = now.add(const Duration(hours: 24));
    return hourlyData.where((hour) {
      final time = DateTime.fromMillisecondsSinceEpoch(hour['dt'] * 1000);
      return time.isAfter(now) && time.isBefore(next24);
    }).map((e) => e as Map<String, dynamic>).toList();
  }

}

