import 'package:flutter/material.dart';
import 'splash.dart'; // Import your SplashScreen widget
import 'config.dart'; // Mengimpor AppConfig dari config.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menampilkan base URL dari AppConfig untuk debugging jika perlu
    print('Base URL: ${AppConfig.baseUrl}');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Show SplashScreen on app startup
    );
  }
}
