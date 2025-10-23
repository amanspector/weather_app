import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submitCity(){
    final city = _controller.text.trim();
    if(city.isNotEmpty){
      Navigator.pop(context,city);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B0E11),
      appBar: AppBar(
        title: Text("Search City"),
        backgroundColor: Color(0xFF1E2228),
      ),
      body: Padding(padding: EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter city name",
              hintStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onSubmitted: (_) => _submitCity(),
          ),
          SizedBox(height: 30,),
          ElevatedButton(onPressed: _submitCity, child: Text("Search"))
        ],
      ),),
    );
  }
}
