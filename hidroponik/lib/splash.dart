import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart'; // Import the login screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Widget> _pages = [
    // First Splash Screen Page
    SplashPage(
      image: 'assets/image/logo1.png', // Replace with your logo path
      title: 'Selamat Datang',
      description: 'Solusi Cerdas untuk Monitoring dan Pengelolaan Pertanian Hidroponik.',
    ),
    // Second Splash Screen Page
    SplashPage(
      image: 'assets/image/1.jpg', // Replace with your image path
      description: 'Pastikan tanaman mendapatkan nutrisi optimal dengan pemantauan kadar nutrisi secara real-time. Sistem akan memberi notifikasi saat nutrisi perlu disesuaikan, menjaga pertumbuhan tanaman tetap sehat.',
    ),
    // Third Splash Screen Page
    SplashPage(
      image: 'assets/image/2.jpg', // Replace with your image path
      description: 'Pantau intensitas lampu UV agar tanaman mendapatkan cahaya yang cukup. Aplikasi ini memastikan lampu bekerja sesuai kebutuhan untuk mendukung fotosintesis maksimal.',
    ),
    // Fourth Splash Screen Page
    // SplashPage(
    //   image: 'assets/image/3.jpg', // Replace with your image path
    //   description: 'Jaga ketinggian air pada level ideal. Sistem akan memberi peringatan saat air perlu diisi ulang, mencegah kekeringan dan memastikan kondisi terbaik untuk tanaman.',
    // ),
    // Fifth Splash Screen Page with the "Masuk" button
    SplashPage(
      image: 'assets/image/4.jpg', // Replace with your image path
      description: 'Pantau kondisi tanaman secara otomatis dengan deteksi status baik, buruk, atau siap panen. Aplikasi ini membantu Anda mengetahui kesehatan tanaman dan waktu terbaik untuk memanennya, memastikan hasil panen optimal.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < _pages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Loop back to the first page
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToLoginPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _pages[index];
              },
            ),
          ),
          Padding(
  padding: const EdgeInsets.symmetric(vertical: 10.0),
  child: ElevatedButton(
    onPressed: _goToLoginPage,
    child: Text("Masuk"),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white, // Set text color to white
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    ),
  ),
),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                height: 8.0,
                width: _currentPage == index ? 16.0 : 8.0,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              );
            }),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const SplashPage({
    required this.image,
    this.title = '',
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 20),
          Image.asset(image, height: 200),
          SizedBox(height: 20),
          Text(
            description,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
