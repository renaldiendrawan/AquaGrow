import 'package:flutter/material.dart';
import 'beranda.dart'; // Import halaman Beranda
import 'riwayat.dart'; // Import halaman Riwayat
import 'tanam.dart'; // Import halaman Tanam
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(), // Ubah home ke LoginScreen untuk halaman pertama
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}

// Halaman utama setelah login
class HomePage extends StatefulWidget {
  final String username; // Menyimpan username dari layar login

  HomePage({required this.username}); // Constructor untuk menerima username

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Set Beranda (index 1) sebagai halaman awal

  // Daftar halaman yang akan ditampilkan berdasarkan indeks
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomeScreen(username: widget.username), // Halaman Beranda
      HistoryScreen(), // Halaman Riwayat
      Tanam(), // Halaman Tanam (baru ditambahkan)
    ]);
  }

  // Fungsi untuk mengganti halaman berdasarkan indeks yang dipilih
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[
          _currentIndex], // Menampilkan halaman berdasarkan indeks yang dipilih
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Menangani onTap untuk berpindah halaman
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.house),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'Tanam',
          ), // Item baru untuk halaman Tanam
        ],
      ),
    );
  }
}
