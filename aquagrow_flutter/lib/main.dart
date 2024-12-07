import 'package:flutter/material.dart';
import 'package:hidroponik/splash.dart';
import 'splash.dart'; // Import splash.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: SplashScreen(), // Ganti home dengan SplashScreen
    );
  }
}
