import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      body: SafeArea(child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/main.png',height: 300,),
            SizedBox(height: 10,),
            Text('Weather app',
              style: TextStyle(color: Colors.white,
                fontSize: 40,
              fontWeight: FontWeight.bold,),),
            SizedBox(height: 10,),
            Text('Your personal weather companion',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),),
            SizedBox(height: 30,),

            ElevatedButton(onPressed: ()=>{

              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()))
            },style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: CircleBorder(),
              padding: EdgeInsets.all(20),
            ), child: Icon(Icons.arrow_forward_ios,
              color: Colors.white,
              size: 25,))
          ],
        ),
      )),
    );
  }
}
