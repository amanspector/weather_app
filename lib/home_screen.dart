import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B0E11),
      appBar: AppBar(
        backgroundColor: Colors.grey,
      ),
      body: SafeArea(
        child: Center(
          child: Text("Home screen of weather app",style: TextStyle(color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,)),
        ),
      ),
    );
  }
}

