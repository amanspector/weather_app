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
      var kl = weatherdata['main']['temp'];
      var cel = kl - 273.15;
      var condition = weatherdata['weather'][0]['main'];

      setState(() {
        _city = city;
        _temperature =
        (cel is num) ? "${cel.toStringAsFixed(1)}°C" : "--°C";
        _condition = condition ?? "--";
        _isLoading = false;
      });
    } else {
      setState(() {
        _city = city;
        _temperature = "--°C";
        _condition = "Unable to fetch weather";
        _isLoading = false;
      });
    }
  } catch (e) {
  setState(() {
  _city = "Error fetching location";
  _temperature = "--°C";
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
              ),):Padding(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on ,color: Colors.blueAccent,),
                    SizedBox(width: 8,),
                    Text(_city,style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),)
                  ],
                ),
                SizedBox(height: 40),
                Icon(
                  Icons.wb_sunny_rounded,
                  color: Colors.orangeAccent,
                  size: 100,
                ),

                SizedBox(height: 20,),

                Text(
                  _temperature,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  _condition,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                  ),
                ),

                SizedBox(height: 40),


                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    "Refresh Location",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
        ],
            ),
          ),
      ),
    );
  }
}

